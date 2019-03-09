local Toast = class("Toast")

function Toast:show(text, delay)
    
    delay = delay or 0.5
    
    local layer = cc.Layer:create()
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.TOAST_UI)
    layer:addChild(ui)
    
    local panel = ui:getChildByName("Image_1")
    local lbl = panel:getChildByName("Label_2")
    
    lbl:setString(text)

    local delayTime = cc.DelayTime:create(delay)
    local moveBy = cc.MoveBy:create(0.5, cc.p(0, 60))
    local fadeOut = cc.FadeOut:create(0.5)
    local removeSelf = cc.CallFunc:create(function() layer:removeFromParent(true) end)
    
    panel:runAction(cc.Sequence:create(delayTime,cc.Spawn:create(moveBy, fadeOut), removeSelf))
    cc.Director:getInstance():getRunningScene():addChild(layer, 10000000)
end


return Toast