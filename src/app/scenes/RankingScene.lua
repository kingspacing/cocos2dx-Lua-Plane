local RankingScene = class("RankingScene",function()
    return cc.Scene:create()
end)

function RankingScene:ctor()
    isEnter = false
    local RankingLayer = require("app.layers.RankingLayer")
    local TopLayer = require("app.layers.TopLayer")

    self:addChild(RankingLayer.new())

    local topLayer = TopLayer.new()
    self:addChild(topLayer)
    topLayer:setName("TopLayer")
end

return RankingScene