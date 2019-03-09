local MainMap = class("MainMap",function()
    return cc.Layer:create()
end)

function MainMap:ctor(param)
    local dataLevel = require "tables.dataLevel"

    local index
    if param.id == nil then
        index = 1
    else
        index = dataLevel.getLevel(param.id).sceneID
    end
    if index > 6 or index < 1 then
        index = 1
    end
    print(index.."/////////")
    
    self.bgSpeed = 2
    self.mgSpeed = 4
    self.fgSpeed = 8
    self.bgs = {}
    self.mgs = {}
    self.fgs = {}
    self.index = index
    if index == 1 or index == 3 then
        self.bgH = 1140
        self.mgH = 1140
        self.fgH = 1140
    elseif index == 2 then
        self.bgH = 1140
        self.fgH = 640
    elseif index == 4 or index == 5 then
        self.bgH = 1140
        self.mgH = 1140
        self.fgH = 640
    elseif index == 6 then
        self.bgH = 1140
        self.mgH = 1140
        self.fgH = 640
    end
    
    for i = 1, 2 do
        self.bgs[i] = display.newSprite("images/pics/bg" .. index .. ".jpg", display.cx, (i-1)*self.bgH)
        self.bgs[i]:setAnchorPoint(0.5, 0)
        self:addChild(self.bgs[i], -2)
    end

    if index == 1 or index == 3 then
        for i = 1, 2 do
            self.mgs[i] = display.newSprite("#mg" .. index .. "_1.png", display.cx, (i-1)*self.mgH)
            self.mgs[i]:setAnchorPoint(0.5, 0)
            self.mgs[i]:setScale(2)
            self:addChild(self.mgs[i], -1)
        end
        for i = 1, 3 do
            self.fgs[i] = display.newSprite("#fg" .. 4 .. "_" .. i .. ".png", math.random(0, display.width), (i-1)*self.fgH)
            self.fgs[i]:setAnchorPoint(0.5, 0)
            self.fgs[i]:setScale(2)
            self:addChild(self.fgs[i], -1)
        end
    elseif index == 2 then
        for i = 1, 3 do
            self.fgs[i] = display.newSprite("#fg" .. index .. "_" .. i .. ".png", math.random(0, display.width), (i-1)*self.fgH)
            self.fgs[i]:setAnchorPoint(0.5, 0)
            self.fgs[i]:setScale(2)
            self:addChild(self.fgs[i], -1)
        end
    elseif index == 4 or index == 5 then
        if index == 4 then
            self.bgSpeed = 1
            self.mgSpeed = 2
        end
        for i = 1, 2 do
            self.mgs[i] = display.newSprite("#mg" .. index .. "_1.png", display.cx, (i-1)*self.mgH)
            self.mgs[i]:setAnchorPoint(0.5, 0)
            self.mgs[i]:setScale(2)
            self:addChild(self.mgs[i], -1)
        end
        for i = 1, 3 do
            self.fgs[i] = display.newSprite("#fg" .. index .. "_" .. i .. ".png", math.random(0, display.width), (i-1)*self.fgH)
            self.fgs[i]:setAnchorPoint(0.5, 0)
            self.fgs[i]:setScale(2)
            self:addChild(self.fgs[i], -1)
        end
    elseif index == 6 then
        for i = 1, 2 do
            self.mgs[i] = display.newSprite("#mg" .. index .. "_" .. i ..".png", math.random(0, display.width), (i-1)*self.mgH)
            self.mgs[i]:setAnchorPoint(0.5, 0)
            self.mgs[i]:setScale(2)
            self:addChild(self.mgs[i], -1)
        end
        for i = 1, 3 do
            self.fgs[i] = display.newSprite("#fg" .. index .. "_" .. math.random(1, 2) .. ".png", math.random(0, display.width), (i-1)*self.fgH)
            self.fgs[i]:setAnchorPoint(0.5, 0)
            self.fgs[i]:setScale(2)
            self:addChild(self.fgs[i], -1)
        end
    end
end

function MainMap:onUpdate(dt)
    -- 远景
    for i,v in ipairs(self.bgs) do
        if v:getPositionY() < - self.bgH then 
            v:setPositionY(self.bgH-2*self.bgSpeed)
        else 
            v:setPositionY(v:getPositionY() - self.bgSpeed)
        end
    end
    
    if self.index == 1 or self.index == 3 then
        -- 中景
        for i,v in ipairs(self.mgs) do
            if v:getPositionY() < - self.mgH then
                v:setPositionY(math.random(2, 3)*self.mgH-2*self.mgSpeed)
            else
                v:setPositionY(v:getPositionY() - self.mgSpeed)
            end
        end
--        -- 前景
--        for i,v in ipairs(self.fgs) do
--            if v:getPositionY() < - self.fgH then
--                v:setPositionY(math.random(2, 3)*self.fgH-2*self.fgSpeed)
--            else
--                v:setPositionY(v:getPositionY() - self.fgSpeed)
--            end
--        end
        -- 前景
        for i,v in ipairs(self.fgs) do
            if v:getPositionY() < - self.fgH then
                v:setPositionY(math.random(3, 5)*self.fgH-2*self.fgSpeed)
                v:setPositionX(math.random(0, display.width))
                local scale = math.random(1, 2)
                v:setScale(scale, scale)
            else
                v:setPositionY(v:getPositionY() - self.fgSpeed)
            end
        end
    elseif self.index == 2 then
        -- 前景
        for i,v in ipairs(self.fgs) do
            if v:getPositionY() < - self.fgH then
                v:setPositionY(math.random(3, 5)*self.fgH-2*self.fgSpeed)
                v:setPositionX(math.random(0, display.width))
                local scale = math.random(1, 2)
                v:setScale(scale, scale)
            else
                v:setPositionY(v:getPositionY() - self.fgSpeed)
            end
        end
    elseif self.index == 4 or self.index == 5 then
        -- 中景
        for i,v in ipairs(self.mgs) do
            if v:getPositionY() < - self.mgH then
                v:setPositionY(self.mgH-2*self.mgSpeed)
            else
                v:setPositionY(v:getPositionY() - self.mgSpeed)
            end
        end
        -- 前景
        for i,v in ipairs(self.fgs) do
            if v:getPositionY() < - self.fgH then
                v:setPositionY(math.random(3, 5)*self.fgH-2*self.fgSpeed)
                v:setPositionX(math.random(0, display.width))
                local scale = math.random(1, 2)
                v:setScale(scale, scale)
            else
                v:setPositionY(v:getPositionY() - self.fgSpeed)
            end
        end
    elseif self.index == 6 then
        -- 中景
        for i,v in ipairs(self.mgs) do
            if v:getPositionY() < - self.mgH then
                v:setPositionY(self.mgH-2*self.mgSpeed)
                v:setPositionX(math.random(0, display.width))
            else
                v:setPositionY(v:getPositionY() - self.mgSpeed)
            end
        end
        -- 前景
        for i,v in ipairs(self.fgs) do
            if v:getPositionY() < - self.fgH then
                v:setPositionY(math.random(3, 5)*self.fgH-2*self.fgSpeed)
                v:setPositionX(math.random(0, display.width))
                local scale = math.random(1, 2)
                v:setScale(scale, scale)
            else
                v:setPositionY(v:getPositionY() - self.fgSpeed)
            end
        end
    end
end

return MainMap
