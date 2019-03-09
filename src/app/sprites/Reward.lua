R_STAR1 = 1
R_STAR2 = 2
R_STAR3 = 3
R_WEAPON_UP1 = 4
R_WEAPON_UP2 = 5
R_PROTECT = 6
R_HP_UP = 7

-- 自由状态
R_STATE_FREE = 1
-- 跟踪状态
R_STATE_SEEK = 2
-- 无效状态
R_STATE_INACTIVE = 3
-- 刚出来停顿状态
R_STATE_WAIT = 4


function createReward(x, y, t, isEndless)
    local sprite
--    display.addSpriteFramesWithFile(GAME_IMAGE.REWARD_FILE, GAME_IMAGE.REWARD_IMAGE)
    --显示奖励动画
    local function showAnimation(str,n)
        if cc.AnimationCache:getInstance():getAnimation(str.."1.png") == nil then
            local p = {}
            --加载道具动画
            for i = 1, n do
                table.insert(p, display.newSpriteFrame(str..i..".png"))
            end
            local animation = cc.Animation:createWithSpriteFrames(p, 0.2)
            cc.AnimationCache:getInstance():addAnimation(animation,str.."1.png")
        end
        local sp = display.newSprite("#"..str.."1.png",x,y)
        local action = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation(str.."1.png"))
        sp:runAction(cc.RepeatForever:create(action))
        return sp
    end
    local function showProp(str,n)
        if n <= 4 and n >= 1 then
            sprite = display.newSprite("#"..str..".png",x,y)
            local temp_sp
            if n == 1 then
                temp_sp = display.newSprite("#prop_2ji1.png", x, y)
            elseif n == 2 then
                temp_sp = display.newSprite("#prop_3ji1.png", x, y)
            elseif n == 3 or n == 4 then
                temp_sp = display.newSprite("#prop_jiaxue1.png", x, y)
            end
            temp_sp:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.8,360)))
            temp_sp:setPosition(sprite:getContentSize().width/2,sprite:getContentSize().height/2)
            sprite:addChild(temp_sp,5)
        else
            sprite = showAnimation(str,n)
            sprite:setRotation(math.random(0,360))
        end        
    end
    
    if t == 1 then
    --    sprite = display.newSprite("#r" .. t ..".png", x, y)   
        showProp("coin_",6)  
        sprite:setScale(0.6)   
    elseif t == 2 then
        showProp("coin_",6)
        sprite:setScale(1.1)
    elseif t == 3 then
        showProp("coin_",6)
        sprite:setScale(1.5)
    elseif t == 4 then
        showProp("prop_2ji",1)
    elseif t == 5 then
        showProp("prop_3ji",2)
    elseif t == 6 then
        showProp("prop_hudun",3)
    elseif t == 7 then
        showProp("prop_jiaxue",4)
    end
    
    
    -- 初始状态是等顿状态
    sprite.state = R_STATE_WAIT
    -- 奖励类型
    sprite.type = t
    -- 碰撞测试使用的宽和高
    sprite.hw = sprite:getContentSize().width / 2
    sprite.hh = sprite:getContentSize().height / 2
    -- 计时器
    local time = 0
    -- 速度
    local rateX = 0
    local rateY = 0
    
    function sprite:hit()
        sprite.state = R_STATE_INACTIVE
        self:removeFromParent(true)
    end
    
    function sprite:setTarget(tx, ty)
        if self.state == R_STATE_INACTIVE then
            return
        end
        if tx == nil or ty == nil then
            self.state = R_STATE_FREE
            if self.type <= R_STAR3 then
                rateY = -10
            else
                if math.random(-1,1) > 0 then
                    rateX = 1
                else
                    rateX = -1
                end
                rateY = -2
            end
            return
        end
        local x = self:getPositionX()
        local y = self:getPositionY()
        if self.state == R_STATE_SEEK then
            rateX = (tx - x) / 10
            rateY = (ty - y) / 10
            return
        end
        local d = cc.pGetDistance(cc.p(x, y), cc.p(tx, ty))
        if d < 150 or (isEndless and d < 350) then
            self.state = R_STATE_SEEK
        end
    end
    
    function sprite:setStateFree()
        self.state = R_STATE_FREE
    end
    sprite.isRun = true
    function sprite:run()
        if self.state == R_STATE_INACTIVE then
            return
        end
        
        local x = self:getPositionX()
        local y = self:getPositionY()
        if self.state == R_STATE_WAIT then
            if time == 30 then
                self.state = R_STATE_FREE
                if self.type <= R_STAR3 then
                    rateY = -8
                else
                    if math.random(-1, 1) > 0 then
                        rateX = 1
                    else
                        rateX = -1
                    end
                    rateY = -2
                end
            else
                self:setPositionY(y + 1)
                time = time + 1
            end
            return
        end
        
        if self.state == R_STATE_FREE and self.isRun then
            -- 类型为星钻
            if self.type <= R_STAR3 then
                -- 若星钻不在屏幕内，则状态设置为无效
                if isEndless then
                    if x < -display.cx or x > display.width * 1.5 or y < -display.cx or y > display.height * 1.5 then
                        self.state = R_STATE_INACTIVE
                        return
                    else
                        rateY = rateY-0.15
                        self:setPositionY(y + rateY)
                    end
                else
                    if x < 0 or x > display.width or y < 0 or y > display.height then
                        self.state = R_STATE_INACTIVE
                        return
                    else
                        rateY = rateY-0.15
                        self:setPositionY(y + rateY)
                    end
                end
            else
                if x + rateX > display.width then
                    self:setPositionX(display.width)
                    rateX = -rateX
                elseif x + rateX < 0 then
                    self:setPositionX(0)
                    rateX = -rateX
                else
                    self:setPositionX(x + rateX)
                end
                if y + rateY > display.height then
                    self:setPositionY(display.height)
                    rateY = -rateY
                elseif y + rateY < 0 then
                    self:setPositionY(0)
                    rateY = -rateY
                else
                    self:setPositionY(y + rateY)
                end
            end
        elseif self.state == R_STATE_SEEK then
            self:setPosition(x + rateX, y + rateY)
        end
    end
    
    return sprite
end