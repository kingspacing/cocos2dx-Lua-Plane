local RechargeScene = class("RechargeScene",function()
    return cc.Scene:create()
end)

function RechargeScene:ctor()
    isEnter = false
    local RechargeLayer = require("app.layers.RechargeLayer")
    local TopLayer = require("app.layers.TopLayer")

    self:addChild(RechargeLayer.new())
    
    local param = {}
    param.canClick = false
    local topLayer = TopLayer.new(param)
    self:addChild(topLayer)
    topLayer:setName("TopLayer")
end

return RechargeScene