local RewardLayer = class("RewardLayer",function()
    return cc.Layer:create()
end)

function RewardLayer:ctor(self_param)
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Cj.ExportJson")
    self:addChild(ui)
    
    local Toast = require("app.layers.Toast")
    local dataUi = require("tables.dataUi")
    local dataUser = require("tables.dataUser")
    local PubDialog = require("app.layers.PubDialog")
    
    local panel = ui:getChildByName("Image_18")
    --1关闭  2抽奖  3-9龙珠1-7
    local btn = {
        [1] = panel:getChildByName("Button_16"),
        [2] = panel:getChildByName("Image_24"):getChildByName("Button_25"),
        [3] = panel:getChildByName("Image_24"):getChildByName("Button_26"),
        [4] = panel:getChildByName("Image_24"):getChildByName("Button_26_0"),
        [5] = panel:getChildByName("Image_24"):getChildByName("Button_26_1"),
        [6] = panel:getChildByName("Image_24"):getChildByName("Button_26_2"),
        [7] = panel:getChildByName("Image_24"):getChildByName("Button_26_3"),
        [8] = panel:getChildByName("Image_24"):getChildByName("Button_26_3_4"),
        [9] = panel:getChildByName("Image_24"):getChildByName("Button_26_3_5"),
    }
    --1.拥有龙珠数
    local lbl = {
        [1] = panel:getChildByName("Label_20_0"),
    }
    --指针
    local arrow = cc.Node:create()
    local arrowImg = cc.Sprite:createWithSpriteFrameName("cjzhizhen.png")
    arrowImg:setPosition(0,btn[2]:getContentSize().width / 2 + 10)
    arrow:addChild(arrowImg)
    arrow:setPosition(btn[2]:getContentSize().width / 2,btn[2]:getContentSize().height / 2)
    btn[2]:addChild(arrow,-1)
    
    for i = 1,7 do
        btn[i+2]:setTouchEnabled(false)
    end
    lbl[1]:setString("拥有龙珠数:"..dataUser.getBall())
    
    --UI显示数据
    local function freshUI()
        lbl[1]:setString("拥有龙珠数:"..dataUser.getBall())
        self:getParent():getChildByName("TopLayer"):fresh()
    end
    
    --置灰龙珠按钮
    local gray = {}
    local ballLevel = dataUser.getBallLevel()
    for i = 1,7 do
        if ballLevel[i] == false then
            gray[i] = cc.Sprite:createWithSpriteFrameName("cjlongzhu"..i..".png")
            display.grayNode(gray[i])
            gray[i]:setPosition(btn[i + 2]:getContentSize().width / 2,btn[i + 2]:getContentSize().height / 2)
            btn[i + 2]:addChild(gray[i])
            btn[i + 2]:setTouchEnabled(false)
        end
    end
    
    local function btnAddListener(id)
        --可激活
        local text = ccui.Text:create("可激活","arial",22)
        text:setColor(cc.c3b(255,0,0))
        local size = gray[id]:getContentSize()
        text:setPosition(size.width / 2,size.height / 2)
        gray[id]:addChild(text)
        
        text:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(1,1.1),
                    cc.ScaleTo:create(1,0.9)
                )
            )
        )
        
        --激活处理
        local function handler()
            local dataUser = require("tables.dataUser")
            dataUser.getBallLevel()[id] = true
            dataUser.flushJson()
            gray[id]:removeFromParent(true)
            
            btn[id + 2]:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(1,1.5),
                    cc.ScaleTo:create(1,1)
            ))
            
            freshUI()
            self_param.handler()
            
            print("友盟龙珠")
            MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_LONGZHU,id))
        end
        --按钮触摸
        local function onBtnStart(touch,event)
            local width = gray[id]:getContentSize().width
            local height = gray[id]:getContentSize().height
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0,0,width,height)
            if cc.rectContainsPoint(rect, locationInNode) then
                local param = {}
                param.handler = handler
                param.id = id
                self:addChild(PubDialog.newBallDialog(param))
                return true
            end
            return false
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(false)
        listener:registerScriptHandler(onBtnStart,cc.Handler.EVENT_TOUCH_BEGAN)
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, gray[id])
    end
    
    for i = 1,7 do
        if ballLevel[i] == false then
            btnAddListener(i)
        end
    end

    --转盘对应数字概率
--    local reward = {
--        [1] = 0.2, 
--        [2] = 0.35, 
--        [3] = 0.2, 
--        [4] = 0, 
--        [5] = 0.2, 
--        [6] = 0, 
--        [7] = 0, 
--        [8] = 0.05, 
--    }
    local reward = {}
    for i = 1,8 do
        reward[i] = dataUi.getReward(i).probability
    end

    local percent = {}
    for i = 1,8 do
        if i == 1 then
            percent[i] = reward[i]
        else
            percent[i] = percent[i - 1] + reward[i]
        end   
    end
    if percent[8] ~= 1 then
        print(percent[8])
        print "total probability not 1"
    end

    local flag = false
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    -- 摇奖
    local function roll()
        local num = math.random(1, 100)
        --抽奖数字
        local number
        for i = 1,8 do
            local t
            if i == 1 then
                t = 0
            else
                t = percent[i - 1]
            end 
            if num <= percent[i] * 100 and num > t * 100 then
                number = i
            end
        end
        -- 抽奖动画
        local angle = math.random(360 / 8 * (number - 1) + 22, 360 / 8 * number - 5)
        -- 总角度
        local angleTatol = 360 * 3 + angle - arrow:getRotation()
        -- 摇奖总时间1秒
        local t = 60
        -- 加速度
        local a = 2 * angleTatol / (t * t)
        -- 初速度
        local speed = a * t

        local function update()
            flag = true
            speed = speed - a
            if speed >= 0 then
                arrow:setRotation(arrow:getRotation() + speed)
            else
                flag = false
                arrow:setRotation(arrow:getRotation() % 360)
                local str
                local function save()
                    --存档
                    if number == 1 then
                        str = "龙珠 x1"
                    elseif number == 2 then
                        str = "金币 x3500"
                    elseif number == 3 then
                        str = "龙珠 x10"
                    elseif number == 4 then
                        str = "金币 x1000"
                    elseif number == 5 then
                        str = "龙珠 x5"
                    elseif number == 6 then
                        str = "金币 x8000"
                    elseif number == 7 then
                        str = "龙珠 x2"
                    elseif number == 8 then
                        str = "金币 x15000"
                    end
                    
                    if dataUi.getReward(number).gold ~= nil then
                        dataUser.increaseGold(dataUi.getReward(number).gold)
                    else
                        dataUser.increaseBall(dataUi.getReward(number).ball)
                    end
                    dataUser.flushJson()
                end
                save()
                self:unscheduleUpdate()
                freshUI()
                Toast:show("恭喜获得" .. str)
                
                print("友盟抽奖")
                MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_CHOUJIANG)
                
            end
        end
        self:scheduleUpdateWithPriorityLua(update, 0) 
    end
    
    for i = 1,9 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    self:removeFromParent(true)
                elseif i == 2 then
                    if flag == true then
                        return
                    end
                    local dataUser = require("tables.dataUser")
                    if dataUser.getGold() >= 3000 then
                        roll()
                        dataUser.increaseGold(-3000)
                        dataUser.flushJson()
                        freshUI()
                    else
                    --    MyApp:pay("pay11")
                        local param = {}
                        param.dialogId = 3
                        param.handler = function()
                            local dataUser = require("tables.dataUser")
                            local t = dataUi.getRecharge(5)
                            local rechargeGold = t.gold + t.giftGold
                            dataUser.increaseGold(rechargeGold)
                            dataUser.flushJson()
                            Toast:show("充值成功")
                            self:getParent():getChildByName("TopLayer"):fresh()
                        end
                        self:addChild(PubDialog:newGoldDialog(param))
                    end
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
--    local function paySuccessCallback(event)
--        if event._usedata == "pay11" then
--            
--        elseif event._usedata == "pay0" then
--            MyApp:enterRechargeScene()
--        end
--    end
--    --监听付费点成功付费反馈
--    local listener = cc.EventListenerCustom:create("pay_result", paySuccessCallback)
--    local eventDispatcher = self:getEventDispatcher()
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return RewardLayer