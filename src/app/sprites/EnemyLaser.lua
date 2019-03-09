local EnemyLaser = {}

function EnemyLaser.newLaser(L, WS)
    local sprite = cc.Sprite:create()
    sprite:setPosition(L.x, L.y)
    sprite.attack = L.attack
    
    -- 激光身体
    local laser = cc.Sprite:create()
    laser:setVisible(false)
    sprite:addChild(laser, -1)
    sprite.laser = laser

    -- 激光蓄力
    local xuli = cc.Sprite:create()
    xuli:setVisible(false)
    sprite:addChild(xuli, 1)
    
    local lm
    if L.texture == "bkdmw" then
        lm = cc.Sprite:createWithSpriteFrameName("bkdmw_jg2.png")
    elseif L.texture == "xilu" then
        lm = cc.Sprite:createWithSpriteFrameName("xilu_jg1_1.png")
    end
    local laserWidth = lm:getContentSize().width * L.scaleX
    local laserHeight = lm:getContentSize().height
    local hw = laserWidth * 0.8
    local hh = 1140
    
    local count = math.floor(1140 / laserHeight)
    if 1140 % laserHeight == 0 then
        count = count + 1
    end
    if L.texture == "bkdmw" then
        -- 蓄力
        local sfs= {}
        for i = 1, 7 do
            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bkdmw_xuli1_" .. i .. ".png")
        end
        local animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
        local animate = cc.Animate:create(animation)
        xuli:setAnchorPoint(0.5, 0.5)
        xuli:setScale(4 * L.scaleX)
        xuli:runAction(
            cc.RepeatForever:create(animate)
        )
        
        -- 发射口
        local sp = cc.Sprite:createWithSpriteFrameName("bkdmw_jg1.png")
        sp:setAnchorPoint(0.5, 1)
        sp:setScaleX(L.scaleX)
        laser:addChild(sp)
        local h = sp:getContentSize().height
        
        -- 激光火焰
        local sfs = {}
        for i = 1, 10 do
            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bkdmw_jgt1_" .. i .. ".png")
        end
        for i = 1, count do
            local animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
            local animate = cc.Animate:create(animation)
            -- 火焰
            local l = cc.Sprite:create()
            l:setScale(L.scaleX * 4, 4)
            l:setAnchorPoint(0.5, 1)
            l:setPosition(0, -h - (i - 1) * laserHeight)
            l:runAction(cc.RepeatForever:create(animate))
            laser:addChild(l, 11)
            
            -- 光柱
            l = cc.Sprite:createWithSpriteFrameName("bkdmw_jg2.png")
            l:setScaleX(L.scaleX)
            l:setAnchorPoint(0.5, 1)
            l:setPosition(0, -h - (i - 1) * laserHeight)
            laser:addChild(l)
        end
    elseif L.texture == "xilu" then
        -- 预警
        local sfs= {}
        for i = 1, 7 do
            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bkdmw_xuli1_" .. i .. ".png")
        end
        local animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
        local animate = cc.Animate:create(animation)
        xuli:setAnchorPoint(0.5, 0.55)
        xuli:setScale(4 * L.scaleX)
        xuli:runAction(
            cc.RepeatForever:create(animate)
        )
    
        -- 发射口
        local sp = cc.Sprite:create()
        local sfs= {}
        for i = 1, 9 do
            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("xilu_jgt1_" .. i .. ".png")
        end
        local animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
        local animate = cc.Animate:create(animation)
        sp:setScale(L.scaleX * 4)
        sp:setAnchorPoint(0.48, 0.65)
        sp:runAction(
            cc.RepeatForever:create(animate)
        )
        laser:addChild(sp, 11)
        
        -- 激光
        local sfs = {}
        for i = 1, 7 do
            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("xilu_jg1_" .. i .. ".png")
        end
        
        for i = 1, count do
            local l = cc.Sprite:create()
            l:setScaleX(L.scaleX)
            l:setAnchorPoint(0.5, 1)
            l:setPosition(0, -(i - 1) * laserHeight)
            local animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
            local animate = cc.Animate:create(animation)
            l:runAction(cc.RepeatForever:create(animate))
            laser:addChild(l)
        end
    end
    
    local isFirstjg = true
    local timejg = 0
    local delayTimejg = 0
    
    local isFirstyj = true
    local timeyj = 0
    local delayTimeyj = 0
    function sprite:update()
        -- 预警提前1.5秒出现
        if xuli:isVisible() then
            delayTimeyj = delayTimeyj + 1
            if delayTimeyj == L.delay + 1.5 * 60 then
                delayTimeyj = 0
                xuli:setVisible(false)
            end
        else
            timeyj = timeyj + 1
            if isFirstyj then
                if timeyj == L.firstShootTime - 1.5 * 60 then
                    timeyj = 0
                    isFirstyj = false
                    xuli:setVisible(true)
                end
            else
                if timeyj == L.shootFrequence - 1.5 * 60 then
                    timeyj = 0
                    xuli:setVisible(true)
                end
            end
        end

        -- 激光身体
        if laser:isVisible() then
            delayTimejg = delayTimejg + 1
            if delayTimejg == L.delay then
                delayTimejg = 0
                laser:setVisible(false)
            end
        else
            timejg = timejg + 1
            if isFirstjg then
                if timejg == L.firstShootTime then
                    timejg = 0
                    isFirstjg = false
                    laser:setVisible(true)
                end
            else
                if timejg == L.shootFrequence then
                    timejg = 0
                    laser:setVisible(true)
                end
            end
        end
    end
    
    function sprite:byHit()
        laser:setVisible(false)
        timejg = -timejg
        
        xuli:setVisible(false)
        timeyj = -timeyj
    end
    
    function sprite:getBox()
        local p = laser:convertToWorldSpaceAR(cc.p(0, 0))
        return cc.rect(p.x - hw / 2, p.y - hh, hw, hh)
    end
    
    return sprite
end

return EnemyLaser