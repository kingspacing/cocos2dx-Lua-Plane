local EndlessWinLayer = class("EndlessWinLayer",function()
    return cc.Layer:create()
end)

function EndlessWinLayer:ctor(param)
    local RenameLayer = require("app.layers.RenameLayer")
    local Toast = require("app.layers.Toast")

    local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
    bg:setPosition(display.cx,display.cy)
    self:addChild(bg)

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phbjs.ExportJson")
    self:addChild(ui)
    --1继续  2修改名字
    local btn = {
        [1] = ui:getChildByName("Button_22"),
        [2] = ui:getChildByName("Image_28"):getChildByName("Button_22_0"),
    }
    --1-5 数值从上至下  6当期排名
    local lbl = {
        [1] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_0"),
        [2] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_0_1"),
        [3] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_0_2"),
        [4] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_0_3"),
        [5] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_0_4"),
        [6] = ui:getChildByName("Image_28"):getChildByName("Image_57"):getChildByName("Label_58_1_2_3"),
    }
    --1-6 两个按钮的状态转换
    local img = {
        [1] = btn[1]:getChildByName("Image_26"),
        [2] = btn[1]:getChildByName("Image_23_0"),
        [3] = btn[1]:getChildByName("Image_23"),
        [4] = btn[2]:getChildByName("Image_26"),
        [5] = btn[2]:getChildByName("Image_23_0"),
        [6] = btn[2]:getChildByName("Image_23"),
    }
    
    local function btnUp(id)
        img[(id - 1) * 3 + 1]:setVisible(true)
        img[(id - 1) * 3 + 2]:setVisible(true)
        img[(id - 1) * 3 + 3]:setVisible(false)
    end
    btnUp(1)
    btnUp(2)
    local function btnDown(id)
        img[(id - 1) * 3 + 1]:setVisible(false)
        img[(id - 1) * 3 + 2]:setVisible(false)
        img[(id - 1) * 3 + 3]:setVisible(true)
    end
    btn[2]:setScale(0.8)
    
    param.num = param.num * param.reward

    local dataUser = require "tables.dataUser"
    local ranking = dataUser.getRanking()
    dataUser.getEndlessShop()[1] = 0
    dataUser.getEndlessShop()[2] = 0
    dataUser.getEndlessShop()[4] = 0
    dataUser.getEndlessShop()[5] = 0

    -- 刷新UI之前把控件
    for i, v in ipairs(btn) do
        v:setVisible(false)
    end
    for i, v in ipairs(lbl) do
        v:setVisible(false)
    end
    local ui_data
    --    {   -- 最高分数
    --        score = nil,
    --        -- 排名
    --        position = nil,
    --    }
    local function refresh()
        for i, v in ipairs(btn) do
            v:setVisible(true)
        end
        for i, v in ipairs(lbl) do
            v:setVisible(true)
        end
        if ui_data == nil then
            if param.num > ranking.score then
                ranking.score = param.num
            end
            dataUser.flushJson()
            local dataUser = require "tables.dataUser"
            local ranking = dataUser.getRanking()

            lbl[4]:setString(ranking.score)

            if ranking.rank == 0 then
                lbl[5]:setVisible(false)
                lbl[6]:setString("暂无排名")
            else
                lbl[5]:setString(ranking.rank)
                lbl[6]:setString("当前排名")
            end
        else
            lbl[4]:setString(ui_data.score)
            lbl[5]:setString(ui_data.position)
            lbl[6]:setString("当前排名")
            dataUser.flushJson()
        end

        if param.reward * 100 - 100 == 0 then
        --    lbl[1]:setVisible(false)
            lbl[2]:setVisible(false)
        else
            lbl[2]:setString("本次分数加成"..(param.reward * 100 - 100).."%")

            lbl[1]:runAction(cc.Sequence:create(
                cc.ScaleTo:create(1,1.5),
                cc.ScaleTo:create(1,1)
            ))

            lbl[2]:runAction(cc.Sequence:create(
                cc.ScaleTo:create(1,1.5),
                cc.ScaleTo:create(1,1),
                cc.CallFunc:create(function() lbl[1]:setString((param.num)) end)
            ))
        end

        lbl[1]:setString(param.num)
        lbl[3]:setString(math.floor(param.num / 20))

        dataUser.increaseGold(math.floor(param.num / 20))
        dataUser.flushJson()
    end
    
    local function func1()
    end

    local user_name = "   "
    local function handle(parameters)
        if parameters then
            if parameters.command == "create_user" then
                -- 判断是否是新用户
                print(parameters.user_score)
                if parameters.user_score == 0 then
                    -- 新用户
                    -- 改名弹窗
                    local function cb()
                        print("create cbbbb")
                        -- 已经有数据了，直接使用此数据
                        Chart.submitUserData({
                            userPower = param.power,
                            userScore = param.num
                        }, handle)
                    end
                    local rl = RenameLayer.new(parameters.user_name, cb)
                    self:addChild(rl)
                    print "hehe3"
                else
--                    Chart.submitUserData({
--                        userPower = param.power,
--                        userScore = param.num
--                    }, handle)
                    print "hehe2"
                 -- 已经有数据了，直接使用此数据
                    local dataUser = require "tables.dataUser"
                    local ranking = dataUser.getRanking()
                    local score_tmp = param.num
                    -- 本次通关分数先对比本地分数，取较大值
                    if ranking.score > param.num then
                        score_tmp = ranking.score
                    end
                    -- 将上面的最大值与服务端的分数进行比较，若比服务端分数高，即上传服务端
                    if parameters.user_score <= score_tmp then
                        Chart.submitUserData({
                            userPower = param.power,
                            userScore = score_tmp
                        }, handle)
                    else
                        -- 分数过低，不需要上传服务端
                        -- 刷UI
                        ui_data = {
                            score = parameters.user_score,
                            position = parameters.user_position,
                        }
                        refresh()
                    end
                end
            elseif parameters.command == "submit_user_data" then
                Toast:show("分数提交成功")
                ui_data = {
                    score = parameters.user_score,
                    position = parameters.user_position,
                }
                print "hehe1"
                -- 跟新本地存档
                local dataUser = require "tables.dataUser"
                local ranking = dataUser.getRanking()
                ranking.score = parameters.user_score
                ranking.rank = parameters.user_position
                dataUser.flushJson()
                -- 刷UI
                refresh()
            end
        else
            -- 网络异常
            -- 刷UI
            refresh()
            print "hehe4"
        end
    end
    
    refresh()
    Chart.createUser(handle)
    
    for i = 1,2 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                btnUp(i)
                if i == 1 then
                    MyApp:enterLevelScene(param)
                elseif i == 2 then
                    print "xiu gai"
                    self:getParent():addChild(RenameLayer.new(user_name))
                end
            elseif type == ccui.TouchEventType.began then
                if i == 1 or i == 2 then
                    btnDown(i)
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
end

return EndlessWinLayer