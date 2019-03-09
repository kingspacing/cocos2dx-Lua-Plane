local LevelScene = class("LevelScene",function()
    return cc.Scene:create()
end)

function LevelScene:ctor(param)
    isEnter = false
    local LevelLayer = require("app.layers.LevelLayer")
    local TopLayer = require("app.layers.TopLayer")

    local levelLayer = LevelLayer.new(param)
    self:addChild(levelLayer)

    local topLayer = TopLayer.new()
    self:addChild(topLayer)
    topLayer:setName("TopLayer")
end

return LevelScene