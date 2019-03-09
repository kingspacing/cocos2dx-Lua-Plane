require "app.sprites.Bullet"
require "app.sprites.Fire"
local Data =  require "tables.dataEnemy"
local DataBoss = require "tables.dataBoss"
local EnemyLaser = require "app.sprites.EnemyLaser"
local Enemy = {}
-- 有效状态
Enemy.E_STATE_ACTIVE = 1
-- 死亡状态
Enemy.E_STATE_INACTIVE = 2
-- 燃烧状态
Enemy.E_STATE_BURN = 3

local tuozhan = "pvr.ccz"

--爆炸
local function bomb(x, y ,s, t)
    --粒子
    local an = cc.ParticleSystemQuad:create("particles/enemy_burn.plist")
    an:setPosition(x,y)
    an:setAutoRemoveOnFinish(true)
    cc.Director:getInstance():getRunningScene():addChild(an, 10)
end

function Enemy.new(enemyID, positionID, position, isWarning)
    local eData = Data.getEnemy(enemyID)
    local x = Data.getPosition(positionID).x
    local y = Data.getPosition(positionID).y
    local wjms = false -- 是无尽模式
    
    if position then
        if type(position) == "boolean" then
            wjms = true
        else
            x = position.x
            y = position.y
        end
    end
    local hp = eData.hp
   
    local sprite = cc.Sprite:create()
    sprite.isRemove = false
    sprite.isBoss = false
    sprite.id = enemyID
    -- 解析武器配置表
    sprite.weaponSet = {}
    for i, v in ipairs(eData.weapon) do
        for j, u in ipairs(Data.getWeaponSet(v.id)) do
            u.x = v.x
            u.y = v.y
            table.insert(sprite.weaponSet, u)
        end
    end
    sprite.weaponSet.shootWait = 0
    -- 射击停顿
    sprite.hp = hp
    sprite.unable = false
    sprite.shootWait = 0
    sprite:setPosition(x, y)
    sprite.weapons = {}
    -- 缩放
    sprite:setScale(eData.scale)
    -- 子弹是否跟随战机消失
    sprite.isDisappear = eData.isDisappear
    -- 掉落奖励
    sprite.leave = eData.leave
    -- 状态
    sprite.state = Enemy.E_STATE_ACTIVE

    function sprite:getPos()
        return cc.p(self:getPositionX(), self:getPositionY())
    end
    -- 激光
    sprite.laser = {}
    for i, v in ipairs(eData.laser) do
        local l = EnemyLaser.newLaser(v, sprite.weaponSet)
        l:setPosition(sprite:getContentSize().width / 2 + v.x, sprite:getContentSize().height / 2 + v.y)
        sprite:addChild(l, 10)
        table.insert(sprite.laser, l)
    end

    local shape = eData.trace.shape
    sprite.shape = shape
    local p = {}
    local pTemp = {}
    local pt = {}
    local rate = eData.rate
    local r = eData.rate
    if eData.initRate ~= nil then
        r = eData.initRate
    end
    local acc = 0
    if eData.initTime ~= nil and eData.initRate ~= nil then
        acc = (rate - r) / eData.initTime
    end
    local rData = nil
    --初始化路径
    if shape == 1 or shape == 2 or shape == 3 or shape == 4  then
        local regionID = eData.regionID
        local distance = eData.trace.distance
        if distance == nil then 
            distance = 0
        end
        rData = Data.getRegion(eData.regionID)
        local y1 = rData.y1 - distance
        local y2 = rData.y2 + distance
        if y1 < y2 then
            y1 = (rData.y1 + rData.y2)/2
            y2 = (rData.y1 + rData.y2)/2
        end
        local x1 = rData.x1 + distance
        local x2 = rData.x2 - distance
        if x1 > x2 then
            x1 = (rData.x1 + rData.x2)/2
            x2 = (rData.x1 + rData.x2)/2
        end
        if shape == 1 then  -- 矩形
            pt = {
                cc.pMidpoint(cc.p(x1, y1),cc.p(x2, y2)),
                cc.pMidpoint(cc.p(x1, y1),cc.p(x2, y1)),
                cc.p(x2, y1),
                cc.p(x2, y2),
                cc.p(x1, y2),
                cc.p(x1, y1),
            }
        elseif shape == 2 then  -- 三角形
            pt = {
                cc.pMidpoint(cc.p(x1, y1),cc.p(x2, y2)),
                cc.p((x1 + x2) / 2, y1),
                cc.p(x2, y2),
                cc.p(x1, y2),
            }
        elseif shape == 3 then -- 倒三角形
            pt = {
                cc.pMidpoint(cc.p(x1, y1),cc.p(x2, y2)),
                cc.p(x1, y1),
                cc.p(x2, y1),
                cc.p((x1 + x2) / 2, y2),
            }
        elseif shape == 4 then -- 撞壁
            pt = {
                cc.pMidpoint(cc.p(x1, y1), cc.p(x2, y2))
            }
        end
        p = cc.pNormalize(cc.pSub(pt[1], cc.p(x, y)))
        pTemp = cc.p(p.x, p.y)
        p.x = p.x * r
        p.y = p.y * r
    elseif shape == 5 then -- 直线
        if x < 0 then
            x = 0
        elseif x > display.width then
            x = display.width
        elseif y < 0 then
            y = 0
        elseif y > display.height then
            y = display.height
        end
        local angle = eData.trace.angle
        sprite:setPosition(x, y)
        if wjms and isWarning then
            -- 预警线
            sprite.redline = cc.Sprite:create()
            sprite.redline:setPosition(x, y)
            sprite.redline:setAnchorPoint(0.5, 0)
            sprite.redline:setScale(0.4, 100)
            sprite.redline:setRotation(angle)
            local sfs = {
                cc.SpriteFrame:create("images/pics/redline_1.png", cc.rect(0, 0, 35, 128)),
                cc.SpriteFrame:create("images/pics/redline_2.png", cc.rect(0, 0, 35, 128))
            }
            sprite.redline:runAction(
                cc.RepeatForever:create(
                    cc.Animate:create(
                        cc.Animation:createWithSpriteFrames(sfs, 0.1)
                    )
                )
            )
            sprite:setVisible(false)
            sprite:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function ()
                        sprite:setVisible(true)
                    end)
                )
            )
            cc.Director:getInstance():getRunningScene():addChild(sprite.redline, 1)
        end
        
        p.x = math.sin(math.rad(angle))
        p.y = math.cos(math.rad(angle))
        pTemp = cc.p(p.x, p.y)
        p.x = p.x * r
        p.y = p.y * r
    elseif shape == 6 then -- 贝塞尔曲线
        if eData.trace.type == 1 then
            sprite:setPosition(0, display.height)
            sprite:runAction(
                cc.Sequence:create(
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                    {
                     cc.p(display.width * 0.5, display.cy * 1.9),
                     cc.p(display.width * 0.75, display.cy * 1.75),
                     cc.p(display.width * 0.5, display.cy * 1.5)
                    }),
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                    {
                     cc.p(display.width * 0.25, display.cy * 1.25),
                     cc.p(display.width * 0.5, display.cy * 1.1),
                     cc.p(display.width + 300, display.cy * 0.5)
                    })
            ))
        elseif eData.trace.type == 2 then
            sprite:setPosition(display.width, display.height)
            sprite:runAction(
                cc.Sequence:create(
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.5, display.cy * 1.9),
                            cc.p(display.width * 0.25, display.cy * 1.75),
                            cc.p(display.width * 0.5, display.cy * 1.5)
                        }),
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.75, display.cy * 1.25),
                            cc.p(display.width * 0.5, display.cy * 1.1),
                            cc.p(-300, display.cy * 0.5)
                        })
                ))
        elseif eData.trace.type == 3 then
            sprite:setPosition(display.width, display.cy * 0.5)
            sprite:runAction(
                cc.Sequence:create(
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.5, display.cy * 1.1),
                            cc.p(display.width * 0.25, display.cy * 1.25),
                            cc.p(display.width * 0.5, display.cy * 1.5)
                        }),
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.75, display.cy * 1.75),
                            cc.p(display.width * 0.5, display.cy * 1.9),
                            cc.p(-300, display.height)
                        })
                ))
        elseif eData.trace.type == 4 then
            sprite:setPosition(0, display.cy * 0.5)
            sprite:runAction(
                cc.Sequence:create(
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.5, display.cy * 1.1),
                            cc.p(display.width * 0.75, display.cy * 1.25),
                            cc.p(display.width * 0.5, display.cy * 1.5)
                        }),
                    cc.BezierTo:create(eData.initTime / 60 / 2,
                        {
                            cc.p(display.width * 0.25, display.cy * 1.75),
                            cc.p(display.width * 0.5, display.cy * 1.9),
                            cc.p(display.width + 300, display.height)
                        })
                ))
        elseif eData.trace.type == 5 then
            sprite:setPosition(0, display.height)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                        {
                            cc.p(display.width * 0.25, display.cy * 0.5),
                            cc.p(display.width * 0.5, display.cy * 0.5),
                            cc.p(display.width + 300, display.cy * 0.5)
                        })
                )
        elseif eData.trace.type == 6 then
            sprite:setPosition(display.width, display.height)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.75, display.cy * 0.5),
                        cc.p(display.width * 0.5, display.cy * 0.5),
                        cc.p(-300, display.cy * 0.5)
                    })
            )
        elseif eData.trace.type == 7 then
            sprite:setPosition(display.width, display.cy * 0.5)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.25, display.cy * 1),
                        cc.p(display.width * 0.25, display.cy * 1),
                        cc.p(-300, display.height + 300)
                    })
            )
        elseif eData.trace.type >= 8 then
            sprite:setPosition(0, display.cy * 0.5)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.75, display.cy * 1),
                        cc.p(display.width * 0.75, display.cy * 1),
                        cc.p(display.width + 300, display.height + 300)
                    })
            )
        elseif eData.trace.type == 9 then
            sprite:setPosition(0, display.cy)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.5, display.height * 0.8),
                        cc.p(display.width * 0.75, display.height * 0.75),
                        cc.p(display.width * 0.5, display.height * 0.7),
                        cc.p(- 300, display.cy * 0.5)
                    })
            )
        elseif eData.trace.type == 10 then
            sprite:setPosition(0, display.cy)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.5, display.height * 0.7),
                        cc.p(display.width * 0.75, display.height * 0.75),
                        cc.p(display.width * 0.5, display.height * 0.8),
                        cc.p(- 300, display.height)
                    })
            )
        elseif eData.trace.type == 11 then
            sprite:setPosition(display.width, display.height)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.5, display.height * 0.8),
                        cc.p(display.width * 0.25, display.height * 0.75),
                        cc.p(display.width * 0.5, display.height * 0.7),
                        cc.p(display.width + 300, display.cy * 0.5)
                    })
            )
        elseif eData.trace.type == 12 then
            sprite:setPosition(display.width, display.cy)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.5, display.height * 0.7),
                        cc.p(display.width * 0.25, display.height * 0.75),
                        cc.p(display.width * 0.5, display.height * 0.8),
                        cc.p(display.width + 300, display.height)
                    })
            )
        elseif eData.trace.type == 13 then
            sprite:setPosition(0, display.height)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.25, display.height * 0.5),
                        cc.p(display.width * 0.5, display.height * 0.25),
                        cc.p(display.width * 0.25, display.height * 0.5),
                        cc.p(display.width + 300, display.height)
                    })
            )
        elseif eData.trace.type == 14 then
            sprite:setPosition(display.width, display.height)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.25, display.height * 0.5),
                        cc.p(display.width * 0.5, display.height * 0.25),
                        cc.p(display.width * 0.25, display.height * 0.5),
                        cc.p(- 300, display.height)
                    })
            )
        elseif eData.trace.type == 15 then
            sprite:setPosition(0, display.cy * 0.5)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.25, display.height * 0.7),
                        cc.p(display.width * 0.5, display.height),
                        cc.p(display.width * 0.25, display.height * 0.7),
                        cc.p(display.width + 300, display.height * 0.25)
                    })
            )
        elseif eData.trace.type >= 16 then
            sprite:setPosition(display.width, display.cy * 0.5)
            sprite:runAction(
                cc.BezierTo:create(eData.initTime / 60,
                    {
                        cc.p(display.width * 0.25, display.height * 0.7),
                        cc.p(display.width * 0.5, display.height),
                        cc.p(display.width * 0.25, display.height * 0.7),
                        cc.p(- 300, display.height * 0.25)
                    })
            )
        end
        
        sprite.oldX = sprite:getPositionX()
        sprite.oldY = sprite:getPositionY()
--        sprite:setFlippedY(true)
    end
    
    local index = 1
    function sprite:run() -- 刷新位置
        if not sprite:isVisible() then
            return
        end
        local  isShootWait = false
    	if self.weaponSet.shootWait ~= 0 then
    	   isShootWait = true
    	end
        if self.state ~= Enemy.E_STATE_ACTIVE or isShootWait then
            return
        end
        if shape == 6 then
            local x = self:getPositionX()
            local y = self:getPositionY()
            if x < -200 or x > display.width + 200 or y < -200 or y > display.height + 200 then
                self.state = Enemy.E_STATE_INACTIVE
                self.isRemove = true
            end
            return
        end
        local sPoint = cc.p(self:getPositionX(), self:getPositionY())
        if shape == 1 or shape == 2 or shape == 3 then --形状循环
            local d = math.floor(cc.pGetDistance(sPoint, pt[index]))
            if d <= r then
                if index+1 > #pt then
                    index = 2
                else 
                    index = index + 1
                end
                p = cc.pNormalize(cc.pSub(pt[index], sPoint))
                pTemp = cc.p(p.x, p.y)
                p.x = p.x * rate
                p.y = p.y * rate
                r = rate
            end
            self:setPosition(cc.pAdd(p,sPoint))
        elseif shape == 4 then --撞壁修改
            if sPoint.x + p.x > rData.x2 then
                self:setPositionX(rData.x2)
                p.x = -p.x
            elseif sPoint.x + p.x < rData.x1 then
                self:setPositionX(rData.x1)
                p.x = -p.x
            else
                self:setPositionX(sPoint.x + p.x)
            end
            if sPoint.y + p.y > rData.y1 then
                self:setPositionY(rData.y1)
                p.y = -p.y
            elseif sPoint.y + p.y < rData.y2 then
                self:setPositionY(rData.y2)
                p.y = -p.y
            else
                self:setPositionY(sPoint.y + p.y)
            end
        elseif shape == 5 then -- 出界删除
            if sPoint.x < -200 or sPoint.x > display.width + 200 or sPoint.y < -200 or sPoint.y > display.height + 200 then
                self.state = Enemy.E_STATE_INACTIVE
                self.isRemove = true
                if self.redline then
                    self.redline:removeFromParent(true)
                end
            else
                self:setPosition(cc.pAdd(p,sPoint))
            end
        end
        if (r > rate and acc < 0) or (r < rate and acc > 0) then
            p.x = pTemp.x * r
            p.y = pTemp.y * r
            r = r + acc
        elseif r ~= rate then 
            r = rate
        end
    end 

    return sprite
end

-- 创建敌机
function Enemy.newEnemy(enemyID, positionID, hpFactor, bulletAttackFactor, bulletRateFactor, position, isWarning)
    
    local eData = Data.getEnemy(enemyID)
    local wariningID
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/bikedamowang1.plist", "images/bikedamowang1."..tuozhan)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/bikedamowang2.plist", "images/bikedamowang2."..tuozhan)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/xilu1.plist", "images/xilu1."..tuozhan)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/xilu2.plist", "images/xilu2."..tuozhan)
    -- 佛力沙
--    print("eData.texture.texture = " .. eData.texture.texture)
    if eData.texture.texture == "boss1_1" or eData.texture.texture == "boss1_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("images/fulisha.plist", "images/fulisha."..tuozhan)
        -- 变身前预警id从200 ~ 249
        if eData.texture.texture == "boss1_1" then
            wariningID = 200
            -- 变身后预警id从250 ~ 299
        else
            wariningID = 250
        end

    -- 西鲁
    elseif eData.texture.texture == "boss2_1" or eData.texture.texture == "boss2_2" then
        -- 变身前预警id从300 ~ 349
        if eData.texture.texture == "boss2_1" then
            wariningID = 300
            -- 变身后预警id从350 ~ 399
        else
            wariningID = 350
        end

    -- 贝比
    elseif eData.texture.texture == "boss3_1" or eData.texture.texture == "boss3_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("images/beibi.plist", "images/beibi."..tuozhan)
        -- 变身前预警id从500 ~ 549
        if eData.texture.texture == "boss3_1" then
            wariningID = 500
            -- 变身后预警id从550 ~ 599
        else
            wariningID = 550
        end

    -- 比克大魔王
    elseif eData.texture.texture == "boss4_1" or eData.texture.texture == "boss4_2" then
        -- 变身前预警id从100 ~ 149
        if eData.texture.texture == "boss4_1" then
            wariningID = 100
            -- 变身后预警id从150 ~ 199
        else
            wariningID = 150
        end

        -- 一星邪恶龙
    elseif eData.texture.texture == "boss5_1" or eData.texture.texture == "boss5_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("images/xieeyixinglong.plist", "images/xieeyixinglong."..tuozhan)
        -- 变身前预警id从600 ~ 649
        if eData.texture.texture == "boss5_1" then
            wariningID = 600
            -- 变身后预警id从650 ~ 699
        else
            wariningID = 650
        end

        -- 魔人布欧
    elseif eData.texture.texture == "boss6_1" or eData.texture.texture == "boss6_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("images/morenbuo.plist", "images/morenbuo."..tuozhan)
        -- 变身前预警id从400 ~ 449
        if eData.texture.texture == "boss6_1" then
            wariningID = 400
            -- 变身后预警id从450 ~ 499
        else
            wariningID = 450
        end
    end
    
    local enemy = Enemy.new(enemyID, positionID, position, isWarning)
    -- 碰撞攻击力
    enemy.attack = eData.attack * hpFactor
    -- 变身
    enemy.nextID = eData.nextID
    if enemy.nextID then
        enemy.endless = true
    end
    enemy.isBoss = eData.isBoss
    if enemy.isBoss then
        enemy.id = enemyID
    end

    -- 是否水平镜像
    if eData.isFlippedY == 1 then
--        enemy:setFlippedY(true)
    end
    -- 敌机机体当第一个武器
    enemy.weapons[1] = enemy 
    -- weaponSet引用eData.weapon,用计算射击暂停运动
--    enemy.weaponSet = eData.weapon
    -- 解析武器配置表
    enemy.weaponSet = {}
    enemy.weapon = enemy.weaponSet
    for i, v in ipairs(eData.weapon) do
        for j, u in ipairs(Data.getWeaponSet(v.id)) do
            u.x = v.x
            u.y = v.y
            table.insert(enemy.weaponSet, u)
        end
    end
    if bulletAttackFactor then
        enemy.weapon.bulletAttackFactor = bulletAttackFactor
    end
    if hpFactor then
        enemy.hp = eData.hp * hpFactor
        eData.hp = eData.hp * hpFactor
    end
    
    if bulletRateFactor then
        enemy.weapon.bulletRateFactor = bulletRateFactor
    end
    -- 射击暂停运动
    enemy.weaponSet.shootWait = 0
    local isArmature = false
    local w
    local h
    -- 敌机纹理
    if eData.texture.texture == "enemy4" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g10.plist", "armatures/g10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g10.png", "armatures/g10.plist", "armatures/g1.ExportJson")
        eData.texture.isAction = "g1"
        isArmature = true
    elseif eData.texture.texture == "enemy5" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g20.plist", "armatures/g20.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g20.png", "armatures/g20.plist", "armatures/g2.ExportJson")
        eData.texture.isAction = "g2"
        isArmature = true
    elseif eData.texture.texture == "enemy6" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g30.plist", "armatures/g30.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g30.png", "armatures/g30.plist", "armatures/g3.ExportJson")
        eData.texture.isAction = "g3"
        isArmature = true
    elseif eData.texture.texture == "enemy7" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g40.plist", "armatures/g40.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g40.png", "armatures/g40.plist", "armatures/g4.ExportJson")
        eData.texture.isAction = "g4"
        isArmature = true
    elseif eData.texture.texture == "enemy8" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g50.plist", "armatures/g50.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g50.png", "armatures/g50.plist", "armatures/g5.ExportJson")
        eData.texture.isAction = "g5"
        isArmature = true
    elseif eData.texture.texture == "enemy9" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g60.plist", "armatures/g60.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g60.png", "armatures/g60.plist", "armatures/g6.ExportJson")
        eData.texture.isAction = "g6"
        isArmature = true
    elseif eData.texture.texture == "enemy13" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g70.plist", "armatures/g70.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g70.png", "armatures/g70.plist", "armatures/g7.ExportJson")
        eData.texture.isAction = "g7"
        isArmature = true
    elseif eData.texture.texture == "enemy20" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/g80.plist", "armatures/g80.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/g80.png", "armatures/g80.plist", "armatures/g8.ExportJson")
        eData.texture.isAction = "g8"
        isArmature = true
    elseif eData.texture.texture == "boss1_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b10.plist", "armatures/b10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b10.png", "armatures/b10.plist", "armatures/b1.ExportJson")
        eData.texture.isAction = "b1"
        isArmature = true
    elseif eData.texture.texture == "boss1_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b1_10.plist", "armatures/b1_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b1_10.png", "armatures/b1_10.plist", "armatures/b1_1.ExportJson")
        eData.texture.isAction = "b1_1"
        isArmature = true
    elseif eData.texture.texture == "boss2_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b20.plist", "armatures/b20.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b20.png", "armatures/b20.plist", "armatures/b2.ExportJson")
        eData.texture.isAction = "b2"
        isArmature = true
    elseif eData.texture.texture == "boss2_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b2_10.plist", "armatures/b2_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b2_10.png", "armatures/b2_10.plist", "armatures/b2_1.ExportJson")
        eData.texture.isAction = "b2_1"
        isArmature = true
    elseif eData.texture.texture == "boss3_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b30.plist", "armatures/b30.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b30.png", "armatures/b30.plist", "armatures/b3.ExportJson")
        eData.texture.isAction = "b3"
        isArmature = true
    elseif eData.texture.texture == "boss3_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b3_10.plist", "armatures/b3_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b3_10.png", "armatures/b3_10.plist", "armatures/b3_1.ExportJson")
        eData.texture.isAction = "b3_1"
        isArmature = true
    elseif eData.texture.texture == "boss4_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b40.plist", "armatures/b40.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b40.png", "armatures/b40.plist", "armatures/b4.ExportJson")
        eData.texture.isAction = "b4"
        isArmature = true
    elseif eData.texture.texture == "boss4_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b4_10.plist", "armatures/b4_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b4_10.png", "armatures/b4_10.plist", "armatures/b4_1.ExportJson")
        eData.texture.isAction = "b4_1"
        isArmature = true
    elseif eData.texture.texture == "boss5_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b50.plist", "armatures/b50.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b50.png", "armatures/b50.plist", "armatures/b5.ExportJson")
        eData.texture.isAction = "b5"
        isArmature = true
    elseif eData.texture.texture == "boss5_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b5_10.plist", "armatures/b5_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b5_10.png", "armatures/b5_10.plist", "armatures/b5_1.ExportJson")
        eData.texture.isAction = "b5_1"
        isArmature = true
    elseif eData.texture.texture == "boss6_1" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b60.plist", "armatures/b60.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b60.png", "armatures/b60.plist", "armatures/b6.ExportJson")
        eData.texture.isAction = "b6"
        isArmature = true
    elseif eData.texture.texture == "boss6_2" then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("armatures/b6_10.plist", "armatures/b6_10.png")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b6_10.png", "armatures/b6_10.plist", "armatures/b6_1.ExportJson")
        eData.texture.isAction = "b6_1"
        isArmature = true
    else
        enemy:setSpriteFrame(eData.texture.texture .. ".png")
    end
    
    enemy.warningAction = {}
    -- 创建预警
    if wariningID then
        for i = wariningID, wariningID + 49 do
            local t = Data.getWarning(i)
            if t then
                t.isFirst = true
                local animation = cc.AnimationCache:getInstance():getAnimation(t.texture)
                if not cc.AnimationCache:getInstance():getAnimation(t.texture) then
                    local sfs = {}
                    for i = 1, t.quantity do
                        sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame(t.texture .. "_" .. i .. ".png")
                    end
                    animation = cc.Animation:createWithSpriteFrames(sfs, 0.05)
                    cc.AnimationCache:getInstance():addAnimation(animation, t.texture)
                end
                local warining = cc.Sprite:create()
                warining:setVisible(false)
                warining:runAction(
                    cc.RepeatForever:create(cc.Animate:create(animation))
                )
                warining:setPosition(t.x, t.y)
                warining:setScale(t.scale)
                enemy:addChild(warining, 10)
                t.action = warining
                t.isRunning = false
                t.time = t.cd
                table.insert(enemy.warningAction, t)
            else
                break
            end
        end
    end
    if isArmature then
        enemy.weapon.armature = ccs.Armature:create(eData.texture.isAction)
        enemy.weapon.armature.name = eData.texture.texture
        enemy:addChild(enemy.weapon.armature)
        if enemy.isBoss then
            w = enemy.weapon.armature:getContentSize().width * 0.4 * eData.scale
            h = enemy.weapon.armature:getContentSize().height * 0.4 * eData.scale
        else
            w = enemy.weapon.armature:getContentSize().width * 0.3 * eData.scale
            h = enemy.weapon.armature:getContentSize().height * 0.3 * eData.scale
        end
        enemy:setOpacity(0)
        if eData.texture.isAction ~= 1 then
            enemy.weapon.armature:stopAllActions() 
        end
        enemy.weapon.armature:setScale(eData.scale)
    else
        if enemy.isBoss then
            w = enemy:getContentSize().width * 0.2 * eData.scale
            h = enemy:getContentSize().height * 0.2 * eData.scale
        else
            w = enemy:getContentSize().width * 0.5 * eData.scale
            h = enemy:getContentSize().height * 0.5 * eData.scale
        end
        enemy:setScale(eData.scale)
    end

    -- 血条
    local size = enemy:getContentSize()
    enemy.showHpBar = eData.hpBar
    if not eData.hpBar then
        eData.hpBar = 0
    end
    enemy.hpBar0 = display.newSprite("images/pics/hpBar" .. eData.hpBar .. "_0.png")
    enemy.hpBar0:setPosition(size.width / 2, size.height / 20)
    enemy.hpBar0:setVisible(false)
    enemy.hpBar0:setScale(1 / eData.scale, 1 / eData.scale)
    enemy:addChild(enemy.hpBar0)
    enemy.hpBar1 = ccui.LoadingBar:create("images/pics/hpBar" .. eData.hpBar .. "_1.png", 100)
    enemy.hpBar1:setPosition(size.width / 2, size.height / 20)
    enemy.hpBar1:setVisible(false)
    enemy.hpBar1:setScale(1 / eData.scale, 1 / eData.scale)
    enemy:addChild(enemy.hpBar1)
    
    -- 激光位置校正
    for i, v in ipairs(enemy.laser) do
        v:setPosition(size.width / 2, size.height / 2)
    end
    
    --add liuchao 创建敌机喷射火焰
    local function newJet(t)
        if cc.AnimationCache:getInstance():getAnimation(t.texture) == nil then
            local p = {}
            --加载敌机火焰喷射动画
            for i = 0, 2 do
                table.insert(p, display.newSpriteFrame(t.texture:sub(1,6) .. i .. ".png"))
            end
            local animation = cc.Animation:createWithSpriteFrames(p, 0.01)
            cc.AnimationCache:getInstance():addAnimation(animation,t.texture)
        end

        local a = enemy:getContentSize()
        local jet = display.newSprite("#"..t.texture..".png",a.width/2 + t.x,a.height/2 + t.y)
        jet:setRotation(t.angle)
        enemy:addChild(jet,-1)
        local action = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation(t.texture))
        jet:runAction(cc.RepeatForever:create(action))
    end
    for i, v in ipairs(eData.texture) do
        newJet(v)
    end   
    
    -- 开火
    function enemy:fire(tx, ty)
        if self.state ~= Enemy.E_STATE_ACTIVE then
            return {}
        end
        local x = self:getPositionX()
        local y = self:getPositionY()
        
        -- 预警动画
        for i, v in ipairs(self.warningAction) do
            if v.isFirst then
                if v.time == v.firstTime + v.cd and not v.isRunning then
                    v.action:setVisible(true)
                    v.isRunning = true
                    v.action:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(v.showTime),
                            cc.CallFunc:create(function ()
                                v.isFirst = false
                                v.action:setVisible(false)
                                v.isRunning = false
                                v.time = 0
                            end)
                        )
                    )
                end
            else
                if v.time == v.cd and not v.isRunning then
                    v.action:setVisible(true)
                    v.isRunning = true
                    v.action:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(v.showTime),
                            cc.CallFunc:create(function ()
                                v.action:setVisible(false)
                                v.isRunning = false
                                v.time = 0
                            end)
                        )
                    )
                end
            end
            if not v.isRunning then
                v.time = v.time + 1
            end
        end
        
        -- 返回子弹
        return fire(enemy.weapon, x, y, tx, ty)
    end

    function enemy:getBox()
        local x = self:getPositionX()
        local y = self:getPositionY()
        return cc.rect(x - w/2, y - h/2, w, h)
    end
    
    function enemy:byHit(attack)
        if self.state ~= Enemy.E_STATE_ACTIVE or not self:isVisible() then
            return
        end
        if attack < 0 then
            self.hp = 0
        else
            self.hp = self.hp - attack
        end
        
        if self.shape ~= 5 and self.shape ~= 6 and enemy.showHpBar and not self.isBoss then 
            -- 血条
            self.hpBar0:setVisible(true)
            self.hpBar1:setVisible(true)
            self.hpBar1:setPercent(self.hp / eData.hp * 100)
        end
        -- 击中变红
        self:runAction(cc.Sequence:create(cc.TintTo:create(0.016, 255, 150, 150),cc.DelayTime:create(0.07),cc.TintTo:create(0.016, 255, 255, 255)))
        if isArmature then
            enemy.weapon.armature:runAction(cc.Sequence:create(cc.TintTo:create(0.016, 255, 150, 150),cc.DelayTime:create(0.07),cc.TintTo:create(0.016, 255, 255, 255)))
        end
        self:freshHPBar()
        if self.hp <= 0 or attack == -1 then
            self.hpBar0:setVisible(false)
            self.hpBar1:setVisible(false)
            self:burn()
        end
    end
    -- 敌机燃烧
    function enemy:burn()
        if self.state ~= Enemy.E_STATE_ACTIVE then
            return
        end
        if self.nextID then
            self.endlessDead = true
            self.isBoss = false
            self:stopAllActions()
            self.weapon.armature:getAnimation():playWithIndex(1)
            self.state = nil
            
            -- 变身前 1s后淡出
            self:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.2),
                    cc.FadeOut:create(0.2),
                    cc.CallFunc:create(function ()
                        self.state = Enemy.E_STATE_INACTIVE
                        self.isRemove = true
                    end)
                )
            )
            
            -- 创建变身后boss
            local x = self:getPositionX()
            local y = self:getPositionY()
            local tag = self:getTag()
            local e = Enemy.newEnemy(self.nextID, positionID, hpFactor, bulletAttackFactor, bulletRateFactor, cc.p(x, y))
            self:getParent():addChild(e, tag)
            e:setPosition(x, y)
            e.state = Enemy.E_STATE_INACTIVE
            e:setTag(tag)
            e:setOpacity(0)
            local scale = e.weapon.armature:getScale()
            e:setScale(scale * 0.5)
            e.weapon.armature:getAnimation():playWithIndex(1)
            e:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function ()
                        e:setOpacity(255)
                    end),
                    cc.ScaleTo:create(0.5, scale * 1.1),
                    cc.ScaleTo:create(1, scale * 1),
                    cc.CallFunc:create(function ()
                        e.weapon.armature:getAnimation():playWithIndex(2)
                        e.state = Enemy.E_STATE_ACTIVE
                    end)
                )
            )
            
            -- boss剪影
            local jianying
            local apY = 0.5
            local jyScale = 2
            -- 佛力沙
            if e.weapon.armature.name == "boss1_2" then
                jianying = "feili"
                apY = 0.35
            -- 西鲁
            elseif e.weapon.armature.name == "boss2_2" then
                jianying = "shalu"
                apY = 0.24
            -- 贝比
            elseif e.weapon.armature.name == "boss3_2" then
                jianying = "beibi"
                apY = 0.4
            -- 比克大魔王
            elseif e.weapon.armature.name == "boss4_2" then
                jianying = "bike"
                apY = 0.3
            -- 一星邪恶龙
            elseif e.weapon.armature.name == "boss5_2" then
                jianying = "shenlong"
                jyScale = 1.25
            -- 魔人布欧
            elseif e.weapon.armature.name == "boss6_2" then
                jianying = "moren"
                apY = 0.38
            end
            if jianying then
                cc.SpriteFrameCache:getInstance():addSpriteFrames("images/bossbiansheng.plist", "images/bossbiansheng."..tuozhan)
                jianying = cc.Sprite:createWithSpriteFrameName(jianying .. ".png")
                jianying:setAnchorPoint(0.5, apY)
                e:addChild(jianying, 200)
                jianying:setScale(scale * 1.1 * jyScale * 4)
                jianying:setVisible(false)
                jianying:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(1.5),
                        cc.CallFunc:create(function ()
                            jianying:setVisible(true)
                        end),
                        cc.Spawn:create(
                            cc.ScaleTo:create(1, scale * jyScale * 4)
                            ,cc.FadeOut:create(1)
                        )
                        ,cc.RemoveSelf:create()
                    )
                )
                
                -- 收光特效
                local sfs = {}
                for i = 1, 8 do
                    sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bbssg_" .. i .. ".png")
                end
                local animation = cc.Animation:createWithSpriteFrames(sfs, 0.18)
                local animate = cc.Animate:create(animation)
                local shouguang = cc.Sprite:create()
                shouguang:setAnchorPoint(0.5, 0.4)
                shouguang:setScale(8)
                shouguang:runAction(
                    cc.Sequence:create(
                        animate,
                        cc.RemoveSelf:create()
                    )
                )
                e:addChild(shouguang, 201)
                
                -- 爆炸特效
                local sfs = {}
                for i = 1, 8 do
                    sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bbsbz_" .. i .. ".png")
                end
                local animation = cc.Animation:createWithSpriteFrames(sfs, 0.1)
                animation:setLoops(-1)
                local animate = cc.Animate:create(animation)
                local baozha = cc.Sprite:create()
                baozha:setVisible(false)
                baozha:setAnchorPoint(0.5, 0.4)
                baozha:setScale(8)
                baozha:runAction(
                    animate
                )
                baozha:runAction(
                    cc.Sequence:create(
                        cc.DelayTime:create(0.8),
                        cc.CallFunc:create(function ()
                            baozha:setVisible(true)
                        end),
                        cc.DelayTime:create(1.5),
                        cc.RemoveSelf:create()
                    )
                )
                e:addChild(baozha, 201)
            end
        else
            if self.redline then
                self.redline:removeFromParent(true)
            end
            bomb(self:getPositionX(), self:getPositionY(), 3 * eData.scale, 0)
            self.state = Enemy.E_STATE_INACTIVE
            self.isRemove = true
        end
        if self.isBoss and not self.nextID then
            local x = self:getPositionX()
            local y = self:getPositionY()
            local t = 0
            local function update()
                if t < 10 then
                    t = t + 1
                    return
                else
                    t = 0
                end
                local pX = x + math.random(-w, w)
                local pY = y + math.random(-h, h)
                local an = cc.ParticleSystemQuad:create("particles/enemy_burn.plist")
                an:setScale(math.random(2, 4))
                an:setPosition(pX, pY)
                an:setAutoRemoveOnFinish(true)
                cc.Director:getInstance():getRunningScene():addChild(an, 10)
            end
            self:scheduleUpdateWithPriorityLua(update, 0)
        end
    end
    -- 刷新血量条
    function enemy:freshHPBar()
        if not self.isBoss then
            return
        end
        local eventDispatcher = self:getEventDispatcher()
        local event = cc.EventCustom:new("MainLayerUI")
        if self.nextID then
            event.type = "bossHP_1"
        else 
            event.type = "bossHP_2"
        end
        event.data = math.floor(self.hp / eData.hp * 100)
        eventDispatcher:dispatchEvent(event)
    end
    
    enemy:freshHPBar()
    
    
    local function onNodeEvent(event)
        if "exit" == event then
            if eData.texture.texture == "enemy4" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g1.ExportJson")
            elseif eData.texture.texture == "enemy5" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g2.ExportJson")
            elseif eData.texture.texture == "enemy6" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g3.ExportJson")
            elseif eData.texture.texture == "enemy7" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g4.ExportJson")
            elseif eData.texture.texture == "enemy8" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g5.ExportJson")
            elseif eData.texture.texture == "enemy9" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g6.ExportJson")
            elseif eData.texture.texture == "enemy13" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g7.ExportJson")
            elseif eData.texture.texture == "enemy20" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/g8.ExportJson")
            elseif eData.texture.texture == "boss1_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b1.ExportJson")
            elseif eData.texture.texture == "boss1_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b1_1.ExportJson")
            elseif eData.texture.texture == "boss2_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b2.ExportJson")
            elseif eData.texture.texture == "boss2_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b2_1.ExportJson")
            elseif eData.texture.texture == "boss3_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b3.ExportJson")
            elseif eData.texture.texture == "boss3_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b3_1.ExportJson")
            elseif eData.texture.texture == "boss4_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b4.ExportJson")
            elseif eData.texture.texture == "boss4_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b4_1.ExportJson")
            elseif eData.texture.texture == "boss5_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b5.ExportJson")
            elseif eData.texture.texture == "boss5_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b5_1.ExportJson")
            elseif eData.texture.texture == "boss6_1" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b6.ExportJson")
            elseif eData.texture.texture == "boss6_2" then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("armatures/b6_1.ExportJson")
            end
        end
    end
    enemy:registerScriptHandler(onNodeEvent)
    
    
    return enemy
end

return Enemy