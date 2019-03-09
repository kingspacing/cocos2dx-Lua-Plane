local RankingLayer = class("RankingLayer",function()
    return cc.Layer:create()
end)

function RankingLayer:ctor()
    local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
    bg:setPosition(display.cx,display.cy)
    self:addChild(bg)

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phb.ExportJson")
    self:addChild(ui)
    --1返回 
    local btn = {
        [1] = ui:getChildByName("Button_61"),
    }

    --    --排名 结构为3*3的数组
    --    local top = {}
    --    for i = 1,3 do
    --        for j = 1,3 do
    --            if j == 1 then
    --                top[i] = {}
    --            end
    --            top[i][j] = panel:getChildByName("Image_39_"..(i-1)):getChildByName("Label_4"..(j-1))
    --        end
    --    end

    --1最高分  2排名  3名字   5当前时间
    local lbl = {
        [1] = ui:getChildByName("Image_86_0"):getChildByName("Label_31"),
        [2] = ui:getChildByName("Image_86_0"):getChildByName("Label_31_0"),
        [3] = ui:getChildByName("Image_86_0"):getChildByName("Label_34"),
        [5] = ui:getChildByName("Image_13"):getChildByName("Image_14"):getChildByName("Label_7"),
    }

    local list = ui:getChildByName("ListView_155")
    --适配  
    list:setContentSize(cc.size(list:getContentSize().width, (display.height - 960) + list:getContentSize().height - 10))   

    self:setVisible(false)
    local top20
    local function fresh()
        self:setVisible(true)
        local date = os.date("*t")

        lbl[1]:setString(top20.user_data.user_score)
        lbl[2]:setString(top20.user_data.user_position)
        local dataUser = require "tables.dataUser"
        local ranking = dataUser.getRanking()
        ranking.rank = top20.user_data.user_position
        ranking.score = top20.user_data.user_score
        dataUser.flushJson()

        if top20.user_data.user_name == "user_name" then
            lbl[3]:setString("暂无名称")
        else
            lbl[3]:setString(top20.user_data.user_name)
        end
        lbl[5]:setString(date.year.."/"..date.month.."/"..date.day)

        local function addTopItem()
            local item = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phb_0.ExportJson")

            local item_lbl = {
                [1] = {
                    [1] = item:getChildByName("Image_41_0"):getChildByName("Label_42_1"),
                    [2] = item:getChildByName("Image_41_0"):getChildByName("Label_42"),
                    [3] = item:getChildByName("Image_41_0"):getChildByName("Label_42_0"),
                },
                [2] = {
                    [1] = item:getChildByName("Image_41_1"):getChildByName("Label_42_1"),
                    [2] = item:getChildByName("Image_41_1"):getChildByName("Label_42"),
                    [3] = item:getChildByName("Image_41_1"):getChildByName("Label_42_0"),
                },
                [3] = {
                    [1] = item:getChildByName("Image_41"):getChildByName("Label_42_1"),
                    [2] = item:getChildByName("Image_41"):getChildByName("Label_42"),
                    [3] = item:getChildByName("Image_41"):getChildByName("Label_42_0"),
                },
            }
            
            for i = 1,3 do
                local data = top20.top20[i]
                item_lbl[i][1]:setString(i)
                item_lbl[i][2]:setString(data.user_name)
                item_lbl[i][3]:setString(data.user_score)
            end

            list:pushBackCustomItem(item)
        end
        addTopItem()

        local function addListItem(id,data)
            local item = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phb_1.ExportJson")

            local item_lbl = {
                [1] = item:getChildByName("Image_41"):getChildByName("Label_42_1"),
                [2] = item:getChildByName("Image_41"):getChildByName("Label_42"),
                [4] = item:getChildByName("Image_41"):getChildByName("Label_42_0"),
            }

            item_lbl[1]:setString(id + 3)
            item_lbl[2]:setString(data.user_name)
            item_lbl[4]:setString(data.user_score)

            list:pushBackCustomItem(item)
        end

        for i = 1,17 do
            if top20.top20[i + 3] ~= nil then
                addListItem(i,top20.top20[i + 3])
            end
        end

        for i = 1,1 do
            local function onBtn(sender,type)
                if type == ccui.TouchEventType.ended then
                    if i == 1 then
                        MyApp:enterIndexScene()
                    end
                end
            end
            btn[i]:addTouchEventListener(onBtn)
        end
    end

    local function handle(parameters)
        if parameters.command == "get_chart" then
            top20 = clone(parameters)
            local dataUser = require "tables.dataUser"
            local ranking = dataUser.getRanking()
            if ranking.score >= top20.user_data.user_score then
                Chart.submitUserData({
                    userPower = math.floor(1000),
                    userScore = ranking.score
                }, handle)
            else
                fresh()
            end
        elseif parameters.command == "submit_user_data" then
            local function cb(para)
                top20 = clone(para)
                fresh()
            end
            Chart.getChart(cb) 
        end
    end
    Chart.getChart(handle)
end

return RankingLayer