local IndexScene = class("IndexScene",function()
    return cc.Scene:create()
end)

function IndexScene:ctor(param)
    isEnter = false
    --播放背景音乐
    require "AudioUtil"
    AudioUtil.init()
    
    AudioUtil.playBGMusic(GAME_SOUND.MENU_BG,true) 
    if AudioUtil.isBgm == true then
        AudioUtil.openBGMusic()
        AudioUtil.openEffect()
    else
        AudioUtil.muteBGMusic()
        AudioUtil.muteEffect()
    end
    
    local IndexLayer = require("app.layers.IndexLayer")
    local TopLayer = require("app.layers.TopLayer")
    
--    cc.Director:getInstance():purgeCachedData()
    local indexLayer = IndexLayer.new(param)
    self:addChild(indexLayer)

    local topLayer = TopLayer.new()
    self:addChild(topLayer)
    topLayer:setName("TopLayer") 
end

return IndexScene