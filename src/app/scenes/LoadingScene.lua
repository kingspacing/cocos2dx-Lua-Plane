local LoadingScene = class("LoadingScene",function()
    return cc.Scene:create()
end)

function LoadingScene:ctor(param)
    isEnter = false
    local loadingLayer = require("app.layers.LoadingLayer").new(param)
    self:addChild(loadingLayer)
    
    --播放背景音乐
    AudioUtil.playBGMusic(GAME_SOUND.MENU_BG,true) 
end

return LoadingScene