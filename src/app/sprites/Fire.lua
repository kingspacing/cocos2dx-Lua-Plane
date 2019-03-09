-- 有效状态
local W_STATE_SHOOT = 1
-- 装弹状态
local W_STATE_WAIT = 2

-- wt:战机武器表
-- x,y:战机位置
-- tx,ty:目标敌机位置
function fire(wt, x, y, tx, ty)
    local bt = {}
    for i, v in ipairs(wt) do
        local flag = false
        if v.state == nil then
            if v.time ~= v.shootFrequence + v.shootFirstTime then
                v.time = v.time + 1
            else
                v.time = v.shootFrequence
                v.state = W_STATE_SHOOT
                v.c = 0
            end
        elseif v.state == W_STATE_WAIT then
            if v.time == v.shootResumeTime then
                v.time = v.shootFrequence
                v.state = W_STATE_SHOOT
                v.c = 0
            else
                v.time = v.time + 1
            end
        elseif v.state == W_STATE_SHOOT then
            if v.time == v.shootFrequence then
                if v.shootQuantity and v.shootResumeTime then
                    v.c = v.c + 1
                    if v.c == v.shootQuantity then
                        v.state = W_STATE_WAIT
                    end
                    -- 计算射击时暂停运动，仅用于敌机
                    if v.shootWait == 1 and v.shootQuantity ~= 1 then
                        if v.c == 1 then
                            wt.shootWait = wt.shootWait + 1
                            if  wt.armature then
                                wt.armature:stopAllActions()
                                wt.armature:runAction(
                                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            wt.armature:getAnimation():playWithIndex(0)
                                        end),
                                        cc.DelayTime:create(0.5),
                                        cc.CallFunc:create(function ()
                                            wt.armature:getAnimation():playWithIndex(1)
                                        end)
                                    )
                                )
                            end
                        elseif v.c == v.shootQuantity then
                            wt.shootWait = wt.shootWait - 1
                            if  wt.armature then
                                wt.armature:stopAllActions()
                                wt.armature:getAnimation():playWithIndex(2)
                            end
                        end
                    end
                end
                v.time = 0
                if not v.unitAngle then
                    flag = true
                else
                    v.unitShootState = true
                end
            else
                if v.unitShootState then
                    v.unitTempTime = v.unitTempTime + 1
                    if v.unitWait == 1 and v.unitQuantity ~= 1 then
                        if v.unitTempQuantity == 1 then
                            wt.shootWait = wt.shootWait + 1
                            if  wt.armature then
                                wt.armature:stopAllActions()
                                wt.armature:runAction(
                                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            wt.armature:getAnimation():playWithIndex(0)
                                        end),
                                        cc.DelayTime:create(0.5),
                                        cc.CallFunc:create(function ()
                                            wt.armature:getAnimation():playWithIndex(1)
                                        end)
                                    )
                                )
                            end
                        elseif v.unitTempQuantity == v.unitQuantity - 1 then
                            wt.shootWait = wt.shootWait - 1
                            if  wt.armature then
                                wt.armature:stopAllActions()
                                wt.armature:getAnimation():playWithIndex(2)
                            end
                        end
                        local d = 0
                        if v.unitShootState then
                            d = (v.unitTime) * (v.unitQuantity - v.unitTempQuantity)
                        else
                            d = v.unitTime
                        end
                        v.bulletType.unitTempDelay = d
                    end
                    if v.unitTempTime == v.unitTime then
                        v.unitTempTime = 0
                        flag = true
                        v.unitTempQuantity = v.unitTempQuantity + 1
                        if v.unitTempQuantity == v.unitQuantity then
                            v.unitTempQuantity = 0
                            v.unitShootState = false
                        end
                        if v.unitTempQuantity == 1 then
                            v.angle = v.unitInitAngle
                        else
                            v.angle = v.angle + v.unitAngle
                        end
                    end
                else
                    v.time = v.time + 1
                end
            end
        end

        if flag == true then
            if not v.shootQuantity and not v.shootResumeTime or v.shootWait == 0 then
                if  wt.armature then
                    wt.armature:stopAllActions()
                    wt.armature:runAction(
                        cc.Sequence:create(
                            cc.CallFunc:create(function ()
                                wt.armature:getAnimation():playWithIndex(0)
                            end),
                            cc.DelayTime:create(0.5),
                            cc.CallFunc:create(function ()
                                wt.armature:getAnimation():playWithIndex(2)
                            end)
                        )
                    )
                end
            end
            
            -- 主角子弹攻击力
            if wt.isPlayer then
--                print("fuck")
                if v.isMain then
                    wt.attack = wt.mainAttack
--                    print("wt.mainAttack = " .. wt.attack)
                else
--                    print("wt.attack = " .. wt.attack)
                end
            end
            
            local wx = x + v.x
            local wy = y + v.y
            local angle = v.angle
            -- 计算角度
            if v.isLock == 1 and tx then        
                angle = math.deg(cc.pGetAngle(cc.p(tx - wx, ty - wy), cc.p(0, 1)))
            end
    
            local bq = v.bulletQueue
            local ox = wx + bq.distance * math.sin(math.rad(angle))
            local oy = wy + bq.distance * math.cos(math.rad(angle))
            -- 竖线
            if bq.shape == 1 then
                local dx = bq.interval * math.sin(math.rad(angle))
                local dy = bq.interval * math.cos(math.rad(angle))
                for j = 1, bq.quantity do
                    local b = createBullet(v.bulletType, wt)
                    b:setPosition(ox + dx * (j - 1), oy + dy * (j - 1))
                    b:setAngle(angle)
                    b.nextAngle = angle
                    b.disperseDelay = v.disperseDelay
                    table.insert(bt, b)
                    b.fireAngle = angle
                end
            -- 横线
            elseif bq.shape == 2 then
                local dx = bq.interval * math.cos(math.rad(180 - angle))
                local dy = bq.interval * math.sin(math.rad(180 - angle))
                for j = 1, bq.quantity do
                    local b = createBullet(v.bulletType, wt)
                    b:setPosition(ox + dx * (j - 1 - (bq.quantity - 1) / 2), oy + dy * (j - 1 - (bq.quantity - 1) / 2))
                    b:setAngle(angle)
                    b.nextAngle = angle
                    b.disperseDelay = v.disperseDelay
                    table.insert(bt, b)
                    b.fireAngle = angle
                end
            -- 扇形
            elseif bq.shape == 3 then
                local cx = ox
                local cy = oy
                for i = 1, bq.radius / bq.interval do
                    for j = 1, bq.quantity do
                        local a = angle
                        if bq.quantity ~= 1 then
                            a = bq.angle / (bq.quantity - 1) * (j - 1) + angle - bq.angle / 2
                        end 
                        local b = createBullet(v.bulletType, wt)
                        b:setPosition(cx + bq.interval * i * math.sin(math.rad(a)), cy + bq.interval * i * math.cos(math.rad(a)))
                        b:setAngle(angle)
                        b.nextAngle = angle
                        b.disperseDelay = v.disperseDelay
                        if v.isDisperse == 1 then
                            b.nextAngle = a
                        end
                        table.insert(bt, b)
                        b.fireAngle = angle
                    end
                end
            -- 圆形
            elseif bq.shape == 4 then
                local cx = ox + bq.radius * math.sin(math.rad(angle))
                local cy = oy + bq.radius * math.cos(math.rad(angle))
                for i = 1, bq.quantity do
                    local b = createBullet(v.bulletType, wt)
                    local a = 360 / bq.quantity * (i - 1) + (180 - angle)
                    --排列角度偏移
                    if bq.rotation then
                        a = a - bq.rotation
                        b:setPosition(cx + bq.radius * math.sin(math.rad(a)), cy + bq.radius * math.cos(math.rad(a)))
                    else
                        b:setPosition(cx + bq.radius * math.sin(math.rad(a)), cy + bq.radius * math.cos(math.rad(a)))
                    end
                    if bq.isDisperse then
                        b.moveAngle = angle
                        b.disperseAngle = a
                    end
                    b:setAngle(angle)
                    b.nextAngle = angle
                    b.disperseDelay = v.disperseDelay
                    if v.isDisperse == 1 then
                        b.nextAngle = a
                    end
                    table.insert(bt, b)
                    b.fireAngle = angle
                end
            -- 不规则
            elseif bq.shape == 5 then
                local cx = ox + bq.radius * math.sin(math.rad(angle))
                local cy = oy + bq.radius * math.cos(math.rad(angle))
                for i = 1, bq.quantity do
                    local b = createBullet(v.bulletType, wt)
                    local a = math.random(0, 360)
                    local r = math.random(0, bq.radius)
                    b:setPosition(cx + r * math.sin(math.rad(a)), cy + r * math.cos(math.rad(a)))
                    b:setAngle(angle)
                    b.nextAngle = angle
                    b.disperseDelay = v.disperseDelay
                    if v.isDisperse == 1 then
                        b.nextAngle = a
                    end
                    table.insert(bt, b)
                    b.fireAngle = angle
                end
            end
        end
    end
    return bt
end