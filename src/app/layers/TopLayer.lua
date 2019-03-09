local TopLayer = class("TopLayer",function()
    return cc.Layer:create()
end)

local dataUser = require("tables.dataUser")
local LicenceLayer = require("app.layers.LicenceLayer")
local dataUi = require("tables.dataUi")

function TopLayer:ctor(param)
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.TOP_LAYER_UI)
    self:addChild(ui)
    
    --1任务  2激活码  3充值  4排行榜
    local btn = {
        [1] = ui:getChildByName("Button_54"),
        [2] = ui:getChildByName("Button_53"),
        [3] = ui:getChildByName("Button_52"),
        [4] = ui:getChildByName("Button_52_0"),
    }
    
    --1金币  2任务数
    local lbl = {
        [1] = ui:getChildByName("Image_20"):getChildByName("Label_46"),
        [2] = ui:getChildByName("Image_35"):getChildByName("Label_36"),
    }
    
    local img = {
        [1] = ui:getChildByName("Image_35"),
    }
    
    self.lbl = lbl
    self.img = img
    lbl[1]:setString(dataUser.getGold())
    self:freshTask()
    
    --充值界面不可点击顶层按钮
    if param and param.canClick == false then
        for i,v in pairs(btn) do
            v:setTouchEnabled(false)
        end
    end
    
    --光点运动
    local tip = cc.Node:create()
    local sp = cc.ParticleSystemQuad:create("particles/tip.plist")
    sp:setPosition(0,0)
    tip:addChild(sp)
    local bx = btn[3]:getContentSize().width / 2
    local by = btn[3]:getContentSize().height / 2
    tip:setPosition(bx - 40,by - 25)
    btn[3]:addChild(tip)
    tip:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveTo:create(0.5,cc.p(bx - 40,by - 25)),
        cc.MoveTo:create(0.5,cc.p(bx - 25,by + 25)),
        cc.MoveTo:create(0.5,cc.p(bx + 40,by + 30)),
        cc.MoveTo:create(0.5,cc.p(bx + 30,by - 25))
    )))
    
    local function update()
        self:freshTask()
    end
    schedule(self,update,0.5)
    
    --每日刷新
    local date = os.date("*t")
    local daily = dataUser.getDaily()
    local level_1 = dataUser.getLevel()
    local level_2 = dataUser.getLimitLevel()
    if daily.day ~= date.day then
        for i,v in pairs(level_1) do
            v.dayLimit = 0
        end
        for i,v in pairs(level_2) do
            v.dayLimit = 0
        end
        daily.day = date.day
        dataUser.flushJson()
    end
    
    local flag = false
    for i = 1,4 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    MyApp:enterAchievementScene()
                    
                    print("友盟成就")
                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_CHENGJIU)
                elseif i == 2 then
                    self:addChild(LicenceLayer.new())
                elseif i == 3 then
                    MyApp:enterRechargeScene()
                elseif i == 4 then
                    if flag then
                        return
                    end
                    flag = true
                    local function handle(data)
                        performWithDelay(self, function ()
                            flag = false
                        end, 1)
                        if data == false then
                            return
                        end
                        MyApp:enterRankingScene()
                    end
                    Chart.getChart(handle)
                    
                    print("友盟排行版")
                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_PAIHANGBANG)
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
--    self:registerScriptHandler(function(event)
--        if  event == "exit" then
--            --记录离开时间
--            local daily = dataUser.getDaily()
--            
--        end
--    end)
end

function TopLayer:freshTask()
    local totalTask = 0
    local t = dataUser.getTask()
    local l = dataUser.getLevel()
    local a = dataUi.getAchievement()

    if a[t.task1] and l[t.task1] and l[t.task1].star >= a[t.task1].passStar then
        totalTask = totalTask + 1
    end
    if a[t.task2] and l[t.task2 - 100] and l[t.task2 - 100].star >= a[t.task2].passStar then
        totalTask = totalTask + 1
    end 
    if a[t.task3.id] and t.task3.killEnemy >= a[t.task3.id].killEnemy then
        totalTask = totalTask + 1
    end 
    if a[t.task4.id] and t.task4.consolidate >= a[t.task4.id].consolidate then
        totalTask = totalTask + 1
    end 
    if a[t.task5.id] and t.task5.upgrade >= a[t.task5.id].upgrade then
        totalTask = totalTask + 1
    end
    
    if totalTask == 0 then
        self.lbl[2]:setVisible(false)
        self.img[1]:setVisible(false)
    else
        self.lbl[2]:setString(totalTask)
    end
end

function TopLayer:fresh()
    local dataUser = require("tables.dataUser")
    self.lbl[1]:setString(dataUser.getGold())
end

return TopLayer