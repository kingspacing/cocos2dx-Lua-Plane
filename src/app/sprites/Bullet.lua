-- 有效状态
B_STATE_ACTIVE = 1
-- 死亡状态
B_STATE_INACTIVE = 2
-- 燃烧状态
B_STATE_BURN = 3
-- 消失状态
B_STATE_INVISIBLE = 4

function createBullet(B, wt)
    local sprite
    -- 判断子弹是否具备动画
    if B.quantity then 
        sprite = display.newSprite("#" .. B.texture .. "_1.png")
        local animation = cc.AnimationCache:getInstance():getAnimation(B.texture)
        -- 先去动画缓冲寻找动画，如果不存在就创建，并加入缓冲
        if animation == nil then
            local t = {}
            for i = 1, B.quantity do
                table.insert(t, display.newSpriteFrame(B.texture .. "_" .. i .. ".png"))
            end
            animation = cc.Animation:createWithSpriteFrames(t, 0.1)
            cc.AnimationCache:getInstance():addAnimation(animation, B.texture)
        end
        sprite:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
    else
        sprite = display.newSprite("#" .. B.texture .. ".png")
    end
    -- 子弹拉伸
    sprite:setScale(B.scaleX, B.scaleY)
    if B.rotation then
        local t = math.abs(1 / B.rotation * 360)
        if B.rotation > 0 then
            sprite:runAction(
                cc.RepeatForever:create(cc.RotateBy:create(t, 360))
            )
        elseif B.rotation < 0 then
            sprite:runAction(
                cc.RepeatForever:create(cc.RotateBy:create(t, -360))
            )
        end
    end
    
    -- 攻击力
    sprite.attack = B.attack
    -- 主角计算，敌机不受影响
    -- 用于主角每发子弹攻击力
    if wt.attack then
        sprite.attack = wt.attack
    end
    -- 用于主角每发子弹技能
    if wt.skill then
        sprite.skill = wt.skill
        -- 暴击
        if sprite.skill.skillName == "暴击" then
            if math.random() < sprite.skill.parameter1 then
                sprite.attack = sprite.attack * sprite.skill.parameter2
            end
        end
    end
    -- 敌机计算，主角不受影响
    -- 子弹攻击力系数，用于计算敌机的
    if wt.bulletAttackFactor then
        sprite.attack = sprite.attack * wt.bulletAttackFactor
    end
    
    -- 是否跟踪
    sprite.isSeek = B.isSeek
    -- 运动速度
    local rate = B.initRate
    if wt.bulletRateFactor then
        rate = rate * wt.bulletRateFactor
    end
    local rateX = 0
    local rateY = 0
    -- 加速度
    local acc = B.acc
    -- 碰撞测试宽和高
    local hw = sprite:getContentSize().width * B.scaleX * 0.5
    local hh = sprite:getContentSize().height * B.scaleY * 0.5
    -- 状态
    sprite.state = B_STATE_ACTIVE
    -- 计时器
    local time = 0
    -- 特殊轨迹
    local traceAngle = 0
    local delay = B.delay
    if B.unitTempDelay then
        delay = B.unitTempDelay + delay
    end
    
    function sprite:byHit()
        if self.state ~= B_STATE_ACTIVE then
            return
        end
        -- 无敌穿透
        if B.hp == -2 then
            return
        elseif B.hp == -1 then
            self:burn()
        end
    end
    
    function sprite:invisible()
        if self.state ~= B_STATE_ACTIVE then
            return
        end
        self.state = B_STATE_INVISIBLE
    end
    
    function sprite:burn()
        if self.state ~= B_STATE_ACTIVE then
            return
        end
        
        local x = self:getPositionX()
        local y = self:getPositionY()
        local angle = self:getRotation()
        x = x + hw * math.sin(math.rad(angle)) * 0.5
        y = y + hh * math.cos(math.rad(angle)) * 0.5
        self.state = B_STATE_INACTIVE
        self:removeFromParent(true)
        local hit = cc.Sprite:create()
        hit:setPosition(x, y)
        cc.Director:getInstance():getRunningScene():addChild(hit, 10)
        hit:setScale(2, 2)
        --序列帧
        hit:setSpriteFrame(display.newSpriteFrame("hit1.png"))
        local action = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("hit"))
        hit:runAction(cc.Sequence:create(action,cc.CallFunc:create(function()
            hit:removeFromParent(true)
        end)))
    end
    
    function sprite:setAngle(angle)
        rateX = rate * math.sin(math.rad(angle))
        rateY = rate * math.cos(math.rad(angle))
        if wt.angle2up and angle ~= 0 then
            self.specialAngle = angle
            return
        end
        if self.disperseAngle then
            self:setRotation(self.disperseAngle)
        else
            self:setRotation(angle)
        end
    end
    local targetTime = 0
    function sprite:setTarget(tx, ty)
        if self.state ~= B_STATE_ACTIVE then
            return
        end
        if time < delay + self.disperseDelay + 3 then
            return
        end
        if targetTime >= 20 then 
            if tx and ty then
                local x = self:getPositionX()
                local y = self:getPositionY()
                local angle = math.deg(cc.pGetAngle(cc.p(tx - x, ty - y), cc.p(0, 1)))
                self:setAngle(angle)
            end
            targetTime = 0
        else 
            targetTime = targetTime + 1
        end
    end

    function sprite:run()
        -- 死亡或燃烧状态直接返回
        if self.state == B_STATE_INACTIVE or self.state == B_STATE_BURN then
            return
        -- 隐身状态等待机体透明度小于0，把子弹设置为死亡状态
        elseif self.state == B_STATE_INVISIBLE then
            local o = self:getOpacity() - 20
            if o < 0 then
                self.state = B_STATE_INACTIVE
                self:removeFromParent(true)
            else
                self:setOpacity(o)
            end
            return
        end
        -- 运动延时计算
        if time < delay then
            time = time + 1
            return
        end
        -- 延时散开
        if time == delay + self.disperseDelay then
            self:setAngle(self.nextAngle)
            self.fireAngle = self.nextAngle
            if self.disperseAngle and self.moveAngle ~= self.nextAngle then
                self.disperseAngle = nil
            end
        end
        -- 主角1号副武器专用
        if wt.angle2up then
            if time == delay + self.disperseDelay + 10 then
                self.specialAngle = 0
            end
        end
        time = time + 1
        
        if (acc > 0 and rate < B.rate) or (acc < 0 and rate > B.rate) then
            rate = rate + acc
            local angle = self:getRotation()
            if wt.angle2up then
                angle = self.specialAngle
            end
            if B.rotation then
                angle = self.fireAngle
            end
            rateX = rate * math.sin(math.rad(angle))
            rateY = rate * math.cos(math.rad(angle))
        end
        if self.disperseAngle then
            rateX = rate * math.sin(math.rad(self.moveAngle))
            rateY = rate * math.cos(math.rad(self.moveAngle))
        end
        -- 当子弹处于有效状态时，才执行下面的处理
        local x = self:getPositionX()
        local y = self:getPositionY()
        local rx = 0
        local ry = 0
        if x < 0 or x > display.width or y < 0 or y > display.height then
            self.state = B_STATE_INACTIVE
            self:removeFromParent(true)
        else
            if B.bulletTrace then
                if B.bulletTrace.rateX and B.bulletTrace.rateY then
                    rx = B.bulletTrace.rateX * math.sin(math.rad(traceAngle))
                    ry = B.bulletTrace.rateY * math.cos(math.rad(traceAngle))
                    traceAngle = traceAngle + 5
                    self:setPosition(x + rateX + rx, y + rateY + ry)
                    
                elseif B.bulletTrace.moveTime1 and B.bulletTrace.moveTime2 and B.bulletTrace.moveAngle then
                    if not self.bstate then
                        self.bstate = "moveTime1"
                        self:runAction(
                            cc.Sequence:create(
                                cc.MoveBy:create(B.bulletTrace.moveTime1, cc.p(rateX * 60 * B.bulletTrace.moveTime1, rateY * 60 * B.bulletTrace.moveTime1)),
                                cc.CallFunc:create(function () self.bstate = "moveTime2" end)
                            )
                        )
                    elseif self.bstate == "moveTime2" then
                        self.bstate = "moveTime3"
                        local angle = self:getRotation() + B.bulletTrace.moveAngle
                        self:runAction(
                            cc.Sequence:create(
                                cc.BezierBy:create(
                                    B.bulletTrace.moveTime2,
                                    {
                                        cc.p(rate * math.sin(math.rad(angle)) * 60 * B.bulletTrace.moveTime2 / 2, rate * math.cos(math.rad(angle)) * 60 * B.bulletTrace.moveTime2 / 2),
                                        cc.p(rate * math.sin(math.rad(angle)) * 60 * B.bulletTrace.moveTime2 / 2, rate * math.cos(math.rad(angle)) * 60 * B.bulletTrace.moveTime2 / 2),
                                        cc.p(rateX * 60 * B.bulletTrace.moveTime2, rateY * 60 * B.bulletTrace.moveTime2),
                                    }
                                ),
                                cc.CallFunc:create(function () self.bstate = "moveTime4" end)
                            )
                        )
                    elseif self.bstate == "moveTime4" then
                        self:setPosition(x + rateX + rx, y + rateY + ry)
                    end
                end
            else
                self:setPosition(x + rateX + rx, y + rateY + ry)
            end
        end
        return cc.rect(x - hw / 2, y - hh / 2, hw, hh) --cc.p(x + rateX + rx, y + rateY + ry)
    end

    function sprite:getBox()
        local x = self:getPositionX()
        local y = self:getPositionY()
        return cc.rect(x - hw / 2, y - hh / 2, hw, hh)
    end
    
    return sprite
end