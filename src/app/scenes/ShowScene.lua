local ShowScene = class("ShowScene",function()
    return cc.Scene:create()
end)

function ShowScene:ctor()
    isEnter = false
    local ShowLayer = require("app.layers.ShowLayer")
    local TopLayer = require("app.layers.TopLayer")

    self:addChild(ShowLayer.new())
    self:addChild(TopLayer.new())
end

return ShowScene