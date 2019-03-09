local EndlessScene = class("EndlessScene",function()
    return cc.Scene:create()
end)

function EndlessScene:ctor(param)
    isEnter = false
    print("EndlessScene...")
    
    local MainMap = require("app.layers.MainMap")
    local MainLayer = require("app.layers.EndlessMainLayer")
    local MainLayerUI = require("app.layers.MainLayerUI")
    
    self:load()
    self.run = true
    self.mainMap = MainMap.new(param)
    self.mainLayer = MainLayer.new(param)
    self.mainLayerUI = MainLayerUI.new(param)
    self:addChild(self.mainMap,0)
    self:addChild(self.mainLayer,1)
    self:addChild(self.mainLayerUI,2)
   
    local function onUpdate(dt)
        if self.run then 
            self.mainMap:onUpdate(dt)
--            self.mainLayer:onUpdate(dt)
        end
    end
    self:scheduleUpdateWithPriorityLua(onUpdate,0)
    
    AudioUtil.playBGMusic(GAME_SOUND.GAME_BG_0, true)
end


function EndlessScene:load()
    
    
end

return EndlessScene
