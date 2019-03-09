local EndlessWinScene = class("EndlessWinScene",function()
    return cc.Scene:create()
end)

function EndlessWinScene:ctor(param)
    isEnter = false
    local EndlessWinLayer = require("app.layers.EndlessWinLayer")
    local TopLayer = require("app.layers.TopLayer")

    self:addChild(EndlessWinLayer.new(param))
    local topLayer = TopLayer.new()
    self:addChild(topLayer)
    topLayer:setName("TopLayer")
end

return EndlessWinScene