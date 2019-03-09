AudioUtil = {}

AudioUtil.isBgm = nil
AudioUtil.isSound = nil

local current = nil

function AudioUtil.init()
    local ud = cc.UserDefault:getInstance()
    local isAudioInit = ud:getBoolForKey("IsAudioInit",false)
    if isAudioInit == false then
        ud:setBoolForKey("IsBgm",true)
        ud:setBoolForKey("IsSound",true)
        ud:setBoolForKey("IsAudioInit",true)
        ud:flush()
        AudioUtil.isBgm = true
        AudioUtil.isSound = true
    else
        AudioUtil.isBgm = ud:getBoolForKey("IsBgm")
        AudioUtil.isSound = ud:getBoolForKey("IsSound")
        
        if AudioUtil.isBgm == true then
            cc.SimpleAudioEngine:getInstance():setMusicVolume(1)
        else
            cc.SimpleAudioEngine:getInstance():setMusicVolume(0)
        end
        
        if AudioUtil.isSound == true then
            cc.SimpleAudioEngine:getInstance():setEffectsVolume(1)
        else
            cc.SimpleAudioEngine:getInstance():setEffectsVolume(0)
        end
    end
end

function AudioUtil.playBGMusic(name, isLoop)
    --延时加载
    if AudioUtil.isBgm == nil then
        AudioUtil.init()
    end
    
    local ud = cc.UserDefault:getInstance()
    AudioUtil.isBgm = ud:getBoolForKey("IsBgm")
    
    if name ~= current then
        isLoop = isLoop == nil and false or isLoop
        if AudioUtil.isBgm == true then
            if current ~= nil then
                cc.SimpleAudioEngine:getInstance():stopMusic()
            end
            current = name
            cc.SimpleAudioEngine:getInstance():playMusic(name,isLoop)
        end
    end
end

function AudioUtil.playEffect(name, isLoop)
    --延时加载
    if AudioUtil.isSound == nil then
        AudioUtil.init()
    end
    
    local ud = cc.UserDefault:getInstance()
    AudioUtil.isSound = ud:getBoolForKey("IsSound")
    
    isLoop = isLoop == nil and false or isLoop
    
    if AudioUtil.isSound == true then
        cc.SimpleAudioEngine:getInstance():playEffect(name, isLoop)  
    end
end

--关闭背景音乐
function AudioUtil.muteBGMusic()
    AudioUtil.isBgm = false
    cc.SimpleAudioEngine:getInstance():setMusicVolume(0)
    cc.UserDefault:getInstance():setBoolForKey("IsBgm",false)
    cc.UserDefault:getInstance():flush()
end

--开启背景音乐
function AudioUtil.openBGMusic()
    AudioUtil.isBgm = true
    cc.SimpleAudioEngine:getInstance():setMusicVolume(1)
    cc.UserDefault:getInstance():setBoolForKey("IsBgm",true)
    cc.UserDefault:getInstance():flush()
end

--关闭音效
function AudioUtil.muteEffect()
    AudioUtil.isSound = false
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(0)
    cc.UserDefault:getInstance():setBoolForKey("IsSound",false)
    cc.UserDefault:getInstance():flush()
end

--开启音效
function AudioUtil.openEffect()
    AudioUtil.isSound = true
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(1)
    cc.UserDefault:getInstance():setBoolForKey("IsSound",true)
    cc.UserDefault:getInstance():flush()
end
