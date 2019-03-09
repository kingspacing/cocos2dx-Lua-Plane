local ServiceLayer = class("ServiceLayer",function()
    return cc.Layer:create()
end)

function ServiceLayer:ctor()
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.SERVICE_LAYER_UI)
    self:addChild(ui)
    
    local btn = ui:getChildByName("Image_18"):getChildByName("Button_26")
    
    local img = {
        [1] = btn:getChildByName("Image_27"),
        [2] = btn:getChildByName("Image_87"),
        [3] = btn:getChildByName("Image_87_0"),
    }
    
    local function btnUp()
        img[1]:setVisible(true)
        img[2]:setVisible(true)
        img[3]:setVisible(false)
    end
    btnUp()
    local function btnDown()
        img[1]:setVisible(false)
        img[2]:setVisible(false)
        img[3]:setVisible(true)
    end

    local function onBtn(sender,type)
        if type == ccui.TouchEventType.ended then
            AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
            btnUp()
            self:removeFromParent(true)
        elseif type == ccui.TouchEventType.began then
            btnDown()
        end
    end
    btn:addTouchEventListener(onBtn)
end

return ServiceLayer