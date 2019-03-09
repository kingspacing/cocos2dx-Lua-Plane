local WinScene = class("WinScene",function()
    return cc.Scene:create()
end)

function WinScene:ctor(param)
    isEnter = false
    local WinLayer = require("app.layers.WinLayer")
    local TopLayer = require("app.layers.TopLayer")
    
    self:addChild(WinLayer.new(param))
    local topLayer = TopLayer.new()
    self:addChild(topLayer)
    topLayer:setName("TopLayer")
end

return WinScene