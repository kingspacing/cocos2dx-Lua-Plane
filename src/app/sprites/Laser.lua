local Laser = {}

function Laser.newLaser(L)
    local sprite = cc.Sprite:create()
    sprite.attack = L.attack
    
    -- 激光头
    local laserTop = cc.Sprite:create()
    if L.scaleX > 1 then
        laserTop:setScale(L.scaleX * 0.5)
    else
        laserTop:setScale(L.scaleX * 0.8)
    end
    local name
    local x = 0
    if L.texture == "swkjg1" then
        name = "swkjgt1"
        x = -4
    elseif L.texture == "swkjg2" then
        name = "swkjgt2"
        x = -4
    elseif L.texture == "swkjg3" then
        name = "swkjgt3"
        x = -4
    elseif L.texture == "wjt_jg1" then
        name = "wjt_jgt1"
        x = -8
    elseif L.texture == "wjt_jg2" then
        name = "wjt_jgt2"
        x = -8
    elseif L.texture == "wjt_jg3" then
        name = "wjt_jgt3"
        x = -8
    end
    laserTop:setPositionX(x)
    local spriteFrames = {
        cc.SpriteFrameCache:getInstance():getSpriteFrame(name .. "_1.png"),
        cc.SpriteFrameCache:getInstance():getSpriteFrame(name .. "_2.png")
    }
    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.1)
    local animate = cc.Animate:create(animation)
    laserTop:runAction(
        cc.RepeatForever:create(animate)
    )
    laserTop:setAnchorPoint(0.5, 0.2)
    sprite:addChild(laserTop, 1)
    
    -- 激光尾
    local laserButtom = cc.Sprite:create()
    if L.scaleX > 1 then
        laserButtom:setScale(L.scaleX * 0.5)
    else
        laserButtom:setScale(L.scaleX * 0.8)
    end
    laserButtom:setPosition(0, 1140)
    local name
    if L.texture == "swkjg1" then
        name = "swkjgw1"
    elseif L.texture == "swkjg2" then
        name = "swkjgw2"
    elseif L.texture == "swkjg3" then
        name = "swkjgw3"
    elseif L.texture == "wjt_jg1" then
        name = "wjt_jgw1"
    elseif L.texture == "wjt_jg2" then
        name = "wjt_jgw2"
    elseif L.texture == "wjt_jg3" then
        name = "wjt_jgw3"
    end
    local spriteFrames = {
        cc.SpriteFrameCache:getInstance():getSpriteFrame(name .. "_1.png"),
        cc.SpriteFrameCache:getInstance():getSpriteFrame(name .. "_2.png")
    }
    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.1)
    local animate = cc.Animate:create(animation)
    laserButtom:runAction(
        cc.RepeatForever:create(animate)
    )
    sprite:addChild(laserButtom, 1)
    
    -- 激光 身体纹理
    local laser = cc.Sprite:createWithSpriteFrameName(L.texture .. ".png")
    local laserWidth = laser:getContentSize().width
    local laserHeight = laser:getContentSize().height
    
    -- 计算需要用多少块纹理拼一条激光)
--    local laserBody = cc.ClippingRectangleNode:create(cc.rect(-laserWidth, 0, laserWidth * 2, 1140))
    local laserBody = cc.ClippingNode:create()
    local stencil = cc.LayerColor:create(cc.c4b(0,0,0,255), display.width, 1140)
--    stencil:setPosition(0, 0)
    stencil:ignoreAnchorPointForPosition(false)
    stencil:setAnchorPoint(0.5,0)
    laserBody:setStencil(stencil)
    laserBody:setInverted(false)
    laserBody:setAlphaThreshold(0)
--    clipper->setStencil(stencil);//设置裁剪模板 //3
--clipper->setInverted(true);//设置底板可见
--clipper->setAlphaThreshold(0);
    sprite:addChild(laserBody)
    local laserBodySet = cc.Sprite:create()
    laserBody:addChild(laserBodySet)
    local count = math.floor(1140 / laserHeight)
    if 1140 % laserHeight ~= 0 then
        count = count + 1
    end
    local laserSet = {}
    for i = 1, count do
        laserSet[i] = cc.Sprite:createWithSpriteFrameName(L.texture .. ".png")
        laserSet[i]:setAnchorPoint(0.5, 0)
        laserSet[i]:setPosition(0, (i - 1) * laserHeight)
        laserBodySet:addChild(laserSet[i])
        laserSet[i]:setScaleX(L.scaleX)
    end
    
    function sprite:setLength(l)
        if L.texture == "swkjg1" or L.texture == "swkjg2" or L.texture == "swkjg3" then
--            laserBody:setClippingRegion(cc.rect(-laserWidth, 50, laserWidth * 2, l - 50))
            stencil:setContentSize( display.width, l)
            laserButtom:setPosition(0, l)
        elseif L.texture == "wjt_jg1" or L.texture == "wjt_jg2" or L.texture == "wjt_jg3" then
--            laserBody:setClippingRegion(cc.rect(-laserWidth, 100, laserWidth * 2, l - 100))
            laserButtom:setPosition(0, l)
            stencil:setContentSize( display.width, l)
        end
    end
    
    local hitWidth = laserWidth * L.scaleX * 0.5
    function sprite:getBox()
        local p = self:convertToWorldSpace(cc.p(0, 0))
        return cc.rect(p.x - hitWidth / 2, p.y, hitWidth, 1140)
    end
    
    
    function sprite:update()
        
    end
    
    local rate = 10
    sprite:scheduleUpdateWithPriorityLua(function ()
        for i, v in ipairs(laserSet) do
            local y = v:getPositionY()
            if y > (count - 1) * laserHeight then
                local index = i + 1
                if index > count then
                    index = 1
                end
                v:setPositionY(laserSet[index]:getPositionY()-laserHeight + rate)
            else
                v:setPositionY(y + rate)
            end
        end
    end, 0)
    
    return sprite
end

return Laser