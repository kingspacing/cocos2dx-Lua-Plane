local PauseLayer = class("PauseLayer",function()
    return cc.Layer:create()
end)

function PauseLayer:ctor(param)
    local GiftLayer = require("app.layers.GiftLayer")
    local PubDialog = require("app.layers.PubDialog")

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PAUSE_LAYER_UI)
    self:addChild(ui)
    
    --1继续战斗  2放弃战斗  3超值礼包
    local btn = {
        [1] = ui:getChildByName("Button_7"),
        [2] = ui:getChildByName("Button_7"):getChildByName("Button_7_0"),
        [3] = ui:getChildByName("Button_7"):getChildByName("Image_21"):getChildByName("Button_22"),
    }
    
    local img = {
        [1] = {
            [1] = btn[1]:getChildByName("Image_8"),
            [2] = btn[1]:getChildByName("Image_9"),
            [3] = btn[1]:getChildByName("Image_9_0"),
        },
        [2] = {
            [1] = btn[2]:getChildByName("Image_8"),
            [2] = btn[2]:getChildByName("Image_9"),
            [3] = btn[2]:getChildByName("Image_9_0"),
        },
        [3] = {
            [1] = btn[3]:getChildByName("Image_20"),
            [2] = btn[3]:getChildByName("Image_4"),
            [3] = btn[3]:getChildByName("Image_4_0"),
        },
    }
    
    local function btnUp(id)
        img[id][1]:setVisible(true)
        img[id][2]:setVisible(true)
        img[id][3]:setVisible(false)
    end
    local function btnDown(id)
        img[id][1]:setVisible(false)
        img[id][2]:setVisible(false)
        img[id][3]:setVisible(true)
    end
    for i = 1,3 do
        btnUp(i)
    end
    
    local dispatcher = self:getEventDispatcher()
    
    for i = 1,3 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    local event = cc.EventCustom:new("MainLayer")
                    event.type = "continue"
                    dispatcher:dispatchEvent(event)
                    self:removeFromParent(true)
                elseif i == 2 then
                    print(param.isEndless)
                    if param.isEndless == true then
                        local dp = {}
                        dp.handler = function()
                            MyApp:enterLoadingScene({toScene = "IndexScene"})
                        end
                        self:addChild(PubDialog:newLeaveEndlessDialog(dp))
                    else
                        MyApp:enterLoadingScene({toScene = "IndexScene"})
                    end
                    
                elseif i == 3 then
                    self:addChild(GiftLayer.new(param))
                end
                btnUp(i)
            elseif type == ccui.TouchEventType.began then
                btnDown(i)
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
end

return PauseLayer