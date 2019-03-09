require "app.sprites.Player"
require "app.sprites.Reward"
local Enemy = require "app.sprites.Enemy"
local DataUser = require "tables.dataUser"
local dataEnemy = require "tables.dataEnemy"

local EndlessLayer = class("EndlessLayer",function()
    return cc.Layer:create()
end)

function EndlessLayer:ctor(param)
    local POSITIONZ_PLAYER = 1
    local POSITIONZ_ENEMY_LAYER = 0
    local POSITIONZ_ENEMY_BULLET_LAYER = 4
    local POSITIONZ_PLAYER_BULLET_LAYER = 3
    local POSITIONZ_REWARD_LAYER = 2

    local rootLayer = display.newLayer()
    
    --- 游戏逻辑各个逻辑层
    local rewardLayer = display.newLayer()
    rootLayer:addChild(rewardLayer, POSITIONZ_REWARD_LAYER)
    local eLayer = display.newLayer()
    rootLayer:addChild(eLayer, POSITIONZ_ENEMY_LAYER)
    local pbLayer = display.newLayer()
    rootLayer:addChild(pbLayer, POSITIONZ_PLAYER_BULLET_LAYER)
    local ebLayer = display.newLayer()
    rootLayer:addChild(ebLayer, POSITIONZ_ENEMY_BULLET_LAYER)
    
    local dataEndlessShop = DataUser.getEndlessShop()
    local endlessShop = {
        -- 天赐
        tianci = dataEndlessShop[1],
        -- 战神祝福
        zhanshenzhufu = dataEndlessShop[2],
        -- 不屈
        buqu = dataEndlessShop[4] * 8,
        -- 蓄势
        xushi = dataEndlessShop[5] * 8,
    }
    for i = 1,5 do
        if i > 2 then
            dataEndlessShop[i] = 0
        end
    end
    DataUser.flushJson()
    
    -- 无尽模式不自动弹出大礼包
    --    if p_id < 100 and p_id > 3 and not DataUser.getBuyGift("level" .. p_id) and DataUser.getGift().buyTime < 2 then
    --        DataUser.setBuyGift("level" .. p_id)
    --        performWithDelay(rootLayer, function ()
    --            local event = cc.EventCustom:new("MainLayerUI")
    --            event.type = "buyGift"
    --            cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    --        end, 1)
    --    end
    
    -- 用于测试必杀持续时间
    local bbTime = 0
    -- 杀敌数量
    local bekillEnemyCount = 0
    
    --- 关卡
    local D =  require "tables.dataEndlessLevel"
    local levelIndex = 1
    local level = D.getLevel(levelIndex)
    --- 存放关卡掉落信息，数据结构如下
    -- {
    --      [1] = {
    --          10分钻石
    --          R_STAR1,
    --          30分钻石
    --          R_STAR2,
    --          100分钻石
    --          R_STAR3,
    --          加血
    --          R_HP_UP,
    --          护盾
    --          R_PROTECT,
    --          武器价钱1级
    --          R_WEAPON_UP1, 
    --          武器价钱2级
    --          R_WEAPON_UP2,
    --      },
    --      [2] = {
    --          ...
    --      }
    -- }
    local levelLeave
    --- boss掉落，数据结构如下
    -- {
    --          10分钻石
    --          R_STAR1,
    --          30分钻石
    --          R_STAR2,
    --          100分钻石
    --          R_STAR3,
    --          加血
    --          R_HP_UP,
    --          护盾
    --          R_PROTECT,
    --          武器价钱1级
    --          R_WEAPON_UP1, 
    --          武器价钱2级
    --          R_WEAPON_UP2,
    -- }
    local bossLeave
    local function createLeave()
        levelLeave = {}
        for i = 1, level.total do
            table.insert(levelLeave, {})
        end

        if level.extendDiamond then
            for i = 1, level.total do
                for j = 1, math.floor(level.extendDiamond / level.total / 30) do
                    table.insert(levelLeave[i], R_STAR2)
                end
            end
            local extendDiamond = level.extendDiamond - math.floor(level.extendDiamond / level.total) * level.total
            for i = 1, extendDiamond do
                local tag = math.random(1, level.total)
                table.insert(levelLeave[tag], R_STAR2)
            end
        end

        if level.levelDiamond and not level.extendDiamond then
            -- 计算关卡掉落
            local levelDiamond = level.levelDiamond
            -- 100分钻石
            local bigDiamond = math.floor(levelDiamond * (math.random() / 1) / 100)
            levelDiamond = levelDiamond - bigDiamond * 100
            -- 30分钻石
            local middleDiamond = math.floor(levelDiamond * (math.random() / 1) / 30)
            levelDiamond = levelDiamond - middleDiamond * 30
            -- 10分钻石
            local smallDiamond = math.floor(levelDiamond / 10)
            -- 分配100分钻石
            for i = 1, bigDiamond do
                local tag = math.random(1, level.total)
                table.insert(levelLeave[tag], R_STAR3)
            end
            -- 分配30分钻石
            for i = 1, middleDiamond do
                local tag = math.random(1, level.total)
                table.insert(levelLeave[tag], R_STAR2)
            end
            -- 分配10分钻石
            for i =1, smallDiamond do
                local tag = math.random(1, level.total)
                table.insert(levelLeave[tag], R_STAR1)
            end
        end
        -- 分配护盾
        for i = 1, level.levelProtect do
            local tag = math.random(1, level.total)
            table.insert(levelLeave[tag], R_PROTECT)
        end
        -- 分配加血
        for i = 1, level.levelAddHp do
            local tag = math.random(1, level.total)
            table.insert(levelLeave[tag], R_HP_UP)
        end
        -- 武器强化1
        for i = 1, level.levelWeaponUp1 do
            local tag = math.random(1, level.total)
            table.insert(levelLeave[tag], R_WEAPON_UP1)
        end
        -- 武器强化2
        for i = 1, level.levelWeaponUp2 do
            local tag = math.random(1, level.total)
            table.insert(levelLeave[tag], R_WEAPON_UP2)
        end

        -- 计算boss掉落
        if level.bossDiamond and not level.extendDiamond then
            -- 分数
            local bossDiamond = level.bossDiamond
            print("fuck ........ " .. bossDiamond)
            -- 100分钻石
            local bigDiamond = math.floor(bossDiamond * (math.random() / 1) / 100)
            bossDiamond = bossDiamond - bigDiamond * 100
            -- 30分钻石
            local middleDiamond = math.floor(bossDiamond * (math.random() / 1) / 30)
            bossDiamond = bossDiamond - middleDiamond * 30
            -- 10分钻石
            local smallDiamond = math.floor(bossDiamond / 10)
            bossLeave = {
                [1] = smallDiamond,
                [2] = middleDiamond,
                [3] = bigDiamond
            }
        end
    end
    createLeave()

    local enemyShoot = true
    local pause = false
    -- 无敌炸弹标识
    local bb = false
    -- 钻石
    local diamond = 0



    --- 创建玩家
    local player = createPlayer(param.enemyPower, param.heroId, 1 + (endlessShop.zhanshenzhufu * 0.3))
    -- 无尽模式
    if endlessShop.xushi > 0 then
        player:setWJBaoqi(true)
        player:runAction(
            cc.MoveTo:create(0.5, cc.p(display.cx, display.cy))
        )
    end
    local playerHp = player.hp
    rootLayer:addChild(player, POSITIONZ_PLAYER)
    local touchBeginPoint = nil
    local touch = false
    local function onTouchBegan(touches, event)
        if pause or player.state == P_STATE_INACTIVE or player.state == P_STATE_BURN or player.wjbaoqi:isVisible() then
            return false
        end
        if not touch then 
            touch = true
            local location = touches[1]:getLocation()
            touchBeginPoint = {x = location.x, y = location.y}
        end
        return true
    end
    local m = 0
    local function onTouchMoved(touches, event)
        if pause or player.state == P_STATE_INACTIVE or player.state == P_STATE_BURN or player.wjbaoqi:isVisible() then
            return false
        end
        if touch and touches[1] then 
            local location = touches[1]:getLocation()
            local pX = player:getPositionX() +location.x - touchBeginPoint.x
            local pY = player:getPositionY() + location.y - touchBeginPoint.y

            -- 飞机侧身
            local d = location.x - touchBeginPoint.x
            if pX < player.w / 4 then
                pX = player.w / 4
            elseif pX > display.width - player.w / 4 then
                pX = display.width - player.w / 4
            end
            if pY < player.h / 4 then
                pY = player.h / 4
            elseif pY > display.height - player.h / 4 then
                pY = display.height - player.h / 4
            end
            player:setPosition(pX, pY)
            touchBeginPoint = {x = location.x, y = location.y}
        end
    end
    local function onTouchEnded(touches, event)
        if touchBeginPoint and cc.pGetDistance(touchBeginPoint, touches[1]:getLocation()) < 10 then
            touch = false
        end
    end
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = rootLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, rootLayer)

    

    --关卡波次
    local index = 1
    --敌机创建计时器
    local time = 0
    --曲线撞机计时器
    local rtime = 0
    --曲线撞机判断是否继续生成撞机怪
    local isRWaveOver = false
    -- 敌机tag计数器
    local c = 0
    local isEnd = false
    -- 计算敌机战斗力系数
    local attackFactor = 1
    local function setAttackFactor(p)
        attackFactor = (p - player:getPower()) / 10000
        if attackFactor < -0.5 then
            attackFactor = -0.5
        elseif attackFactor > 2 then
            attackFactor = 2
        end
        attackFactor = 1 + attackFactor
    end

    --歼灭boss，生成钻石
    local function createBossReward(x, y, id)
        print "createBossReward createBossReward createBossReward createBossReward"
        local function create(x, y, i, ra, t)
            local reward = createReward(x+20-math.random(0,40), y +20-math.random(0,40), ra, true)
            reward.isRun = false
            rewardLayer:addChild(reward, 100 - i)
            reward:setScale(0)
            reward:runAction(cc.Sequence:create(cc.DelayTime:create(t + math.random(1,10)*0.01)
                , cc.ScaleTo:create(0,0.5)
                , cc.Spawn:create(cc.JumpBy:create(0.5,cc.p(200-math.random(0,400), 0), 100,1)
                    , cc.ScaleTo:create(0.5, 1))
                ,cc.CallFunc:create(function()
                    reward.isRun = true
                end)))
        end
        local bl = bossLeave
        local t = {0, 0, 0}
        for j = 1, 3 do
            for i = 1, bl[j] do
                if t[j] <= 3 then 
                    t[j] = t[j] + 0.2
                end
                create(x, y, i, j, t[j])
            end
        end
    end
    -- 创建敌机
    local function createEnemies()
        if not isEnd then
            local t = {}
            for i, v in ipairs(level[index]) do
                if v.time == time then
                    local e
                    local eData = dataEnemy.getEnemy(v.enemyID)
                    if eData.isBoss and not level.isBoss then
                        --警告动画
                        local warLayer = require("app.layers.WarningLayer")
                        local function handler()
                            e = Enemy.newEnemy(v.enemyID, v.positionID, level[index].hpFactor, level[index].bulletAttackFactor * attackFactor, level[index].bulletRateFactor)
                            -- 每一个敌机设置一个tag，用于跟踪子弹和子弹随机体消失而消失的计算
                            c = c + 1
                            e:setTag(c)
                            eLayer:addChild(e, c)
                            table.remove(level[index], i)
                        end

                        rootLayer:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(handler)))
                        local wLayer = warLayer.new()
                        wLayer:setPositionY(display.cy - 480)
                        rootLayer:addChild(wLayer,50)
                        level.isBoss = true
                        --出现boss播放boss音乐
                        AudioUtil.playBGMusic(GAME_SOUND.GAME_BOSS_BG,true)
                    else
                        if level[index].hpFactor then
                            e = Enemy.newEnemy(v.enemyID, v.positionID, level[index].hpFactor, level[index].bulletAttackFactor * attackFactor, level[index].bulletRateFactor, true, level[index].isWarning)
                        else
                            e = Enemy.newEnemy(v.enemyID, v.positionID, 1, 1, 1, true, level[index].isWarning)
                        end

                        -- 每一个敌机设置一个tag，用于跟踪子弹和子弹随机体消失而消失的计算
                        c = c + 1
                        e:setTag(c)
                        eLayer:addChild(e, c)
                        table.insert(t, 1, i)
                    end   
                end
            end 

            for i, v in ipairs(t) do
                table.remove(level[index], v)
            end
            time = time + 1

            if  eLayer:getChildrenCount() == 0 and #level[index] == 0 then
                endlessShop.xushi = endlessShop.xushi - 1
                if endlessShop.xushi == 0 then
                    player:setWJBaoqi(false)
                    player:runAction(
                        cc.MoveTo:create(0.5, cc.p(display.cx, display.cy / 2))
                    )
                end

                if player.wjbaoqi.dead then
                    endlessShop.buqu = endlessShop.buqu - 1
                    if endlessShop.buqu == 0 then
                        MyApp:enterLoadingScene({
                            num = diamond,
                            reward = endlessShop.tianci * 0.5 + 1,
                            heroId = param.heroId,
                            isEndless = true,
                            toScene = "EndlessWinScene"
                        })
                    end
                end
                if index + 1 <= #level  then
                    index = index + 1
                    time = 0
                    rtime = 0
                    isRWaveOver = false
                else
                    -- 下一关
                    levelIndex = levelIndex + 1
                    if levelIndex == 150 then
                        levelIndex = math.random(140, 149)
                    end
                    -- 更新关卡数据
                    level = D.getLevel(levelIndex)
                    -- 波次复位
                    index = 1
                    -- 时间复位
                    time = 0
                    -- 撞击怪时间复位
                    rtime = 0
                    isRWaveOver = false
                    -- 敌机计数标签复位
                    c = 0
                    -- 更新敌机战斗力系数
                    setAttackFactor(level.enemyPower)
                    -- 更新玩家战机攻击力
                    player:setAttackFactor(level.enemyPower)
                    -- 更新物品掉落
                    createLeave()
                    print("This's level is " .. levelIndex)
                end
            end
        else
            for i, v in ipairs(eLayer:getChildren()) do
                v:byHit(-1)
            end
        end
    end
    -- 玩家燃烧瞬间处理的事情
    local function pBurn()
        if player.wjbaoqi.dead then
            return
        end
        
        -- 之前发射子弹全部隐身
        for j, u in ipairs(pbLayer:getChildren()) do
            if u.state == B_STATE_ACTIVE then
                u:invisible()
            end
        end
        --add liuchao 玩家死亡掉落道具
        local x = player:getPositionX()
        local y = player:getPositionY()
        local a = math.random(0, 360)
        local r = math.random(0, 100)
        rewardLayer:addChild(createReward(x + r * math.sin(math.rad(a)),
            y + r * math.cos(math.rad(a)), 6))
        for i = 1,4 do
            local a = math.random(0, 360)
            local r = math.random(0, 100)
            rewardLayer:addChild(createReward(x + r * math.sin(math.rad(a)),
                y + r * math.cos(math.rad(a)), 4))
        end 

        -- 屏幕上的奖励状态变成自由状态
        for i, v in ipairs(rewardLayer:getChildren()) do
            if v.state ~= R_STATE_INACTIVE then
                v.state = R_STATE_FREE
                v:run()
            end
        end        
        local eventDispatcher = rootLayer:getEventDispatcher()
        local event = cc.EventCustom:new("MainLayerUI")
        event.type = "dead"
        event.data = "endlessLevel"
        eventDispatcher:dispatchEvent(event)

    end
    -- 敌机燃烧瞬间处理的事情
    local function eBurn(e)
        if e.endlessDead then
            return
        end
        if e.isBoss then
            print "fuck you!!!!!!!!!!!!!!!!!!!!!!!!"
        end
        
        -- 统计杀敌数量
        bekillEnemyCount = bekillEnemyCount + 1

        local point = e:getPos()
        e.endlessDead = true
        local x = point.x
        local y = point.y
        local tag = e:getTag()
        --歼灭的是boss
        if e.isBoss and not e.nextID and not e.endless then
            createBossReward(x, y, e.id)
        end
        if tag > 0 then
            -- 掉落奖励
            for i, v in ipairs(levelLeave[tag]) do
                local a = math.random(0, 360)
                local r = math.random(0, 100)
                rewardLayer:addChild(createReward(x + r * math.sin(math.rad(a)), y + r * math.cos(math.rad(a)), v, true))
            end
        end
        -- 之前发射子弹全部隐身
        if e.isDisappear == 1 then
            for i, v in ipairs(ebLayer:getChildren()) do
                if v.state == B_STATE_ACTIVE and v:getTag() == tag then
                    v:invisible()
                end
            end
        end  
        if not e.isRemove then 
            e.state = Enemy.E_STATE_ACTIVE
        end
        --播放爆炸音效
        AudioUtil.playEffect(GAME_SOUND.BOOM_EFFECT,false)
    end

    -- 运动
    local function run()
        if bb then
            bbTime = bbTime + 1
        end
        if player.hp == 0 and not player.wjbaoqi.dead then
            return
        end
        --角色碰撞区域
        local r = player:getBox()
        local eRect = {}
        --角色坐标
        local pX = player:getPositionX()
        local pY = player:getPositionY()

        local e
        local distance = 1140
        for i, v in ipairs(eLayer:getChildren()) do
            eRect[#eRect+1] = v:getBox()
            if bb and v.state == Enemy.E_STATE_ACTIVE and v:isVisible() and not v.unable  then
                v:byHit(player.bbAttack)
                if v.state == Enemy.E_STATE_INACTIVE then
                    eBurn(v)
                end
            end
            -- 无尽暴气状态秒杀一切
            if player.wjbaoqi:isVisible() then
                v:byHit(-1)
                eBurn(v)
            end

            local d = cc.pGetDistance(cc.p(pX, pY), v:getPos())
            if distance > d then 
                e = v
                distance = d
            end
            --敌机开火
            local w = v
            -- 敌机激光
            if w.state == Enemy.E_STATE_ACTIVE and w:isVisible() and not w.unable  then
                for j, k in ipairs(w.laser) do
                    if not enemyShoot then
                        k:byHit()
                    else
                        k:update()
                        if k.laser:isVisible() then
                            if cc.rectIntersectsRect(k:getBox(), r) then
                                k:byHit()
                                -- 玩家受攻击
                                player:byHit(k.attack)
                                -- 若玩家状态为燃烧
                                if player.state == P_STATE_BURN then
                                    pBurn()
                                end
                            end
                        end
                    end
                end
            end

            if w:isVisible() then
                if  not w.unable then
                    if enemyShoot then
                        local b = w:fire(pX, pY)
                        for j, u in ipairs(b) do
                            -- 每一个子弹设置一个tag，用于子弹随机体消失而消失的计算
                            u:setTag(v:getTag())
                            -- 如果子弹具备跟踪能力，及记下目标机体tag
                            if u.isSeek == 1 then
                                u.targetTag = player:getTag()
                            end
                            ebLayer:addChild(u)
                        end
                    end
                    --敌机碰撞
                    if w.state == Enemy.E_STATE_ACTIVE and player.state == P_STATE_ACTIVE and player.protect:isVisible() == false then
                        if cc.rectIntersectsRect(w:getBox(), r) then
                            local pHp = player.hp
                            -- 玩家受撞击
                            player:byHit(v.attack)
                            -- 若玩家状态为燃烧
                            if player.state == P_STATE_BURN then
                                pBurn()
                            end
                            -- 敌机受撞击
                            w:byHit(pHp*0.1)
                            if w.state == Enemy.E_STATE_INACTIVE then
                                eBurn(w)
                            end
                        end
                    end
                end
            end
            --敌机运动
            v:run()
        end

        local ex, ey
        if e then
            local point = e:getPos()
            ex = point.x
            ey = point.y
        end
        for i, v in ipairs(player:fire(ex, ey)) do
            for j, u in ipairs(v) do
                pbLayer:addChild(u)
            end
        end
        -- 玩家运动
        player:run()

        -- 敌机子弹
        for i, v in ipairs(ebLayer:getChildren()) do
            -- 追逐子弹重新计算轨迹
            if v.isSeek == 1 and v.state == B_STATE_ACTIVE then
                if player.state == P_STATE_ACTIVE then
                    v:setTarget(pX, pY)
                end
            end
            local vPoint = v:run()
            -- 无敌炸弹有效时，屏幕上面的子弹燃烧
            if bb and v.state then
                v:burn()
            end
            if v.state == B_STATE_ACTIVE and player.state == P_STATE_ACTIVE then
                if cc.rectIntersectsRect(r, v:getBox()) then
                    -- 玩家被击中
                    player:byHit(v.attack)
                    -- 若玩家状态为燃烧
                    if player.state == P_STATE_BURN then
                        pBurn()
                    end
                    -- 敌机子弹命中
                    v:byHit()
                    if v.state ~= B_STATE_ACTIVE then
                        break
                    end
                end
            end
        end

        -- 玩家子弹
        for i, v in ipairs(pbLayer:getChildren()) do
            if v.isSeek == 1 and v.state == B_STATE_ACTIVE  then
                if e then
                    if e.state == Enemy.E_STATE_ACTIVE then
                        v:setTarget(ex, ey)
                    end
                end
            end
            local vPoint = v:run()
            local index = 1
            for j, u in ipairs(eLayer:getChildren()) do
                if v.state ~= B_STATE_ACTIVE then
                    break
                end
                if u.state == Enemy.E_STATE_ACTIVE and u:isVisible() and not u.unable then
                    if vPoint and #eRect >= index and cc.rectIntersectsRect(eRect[index], vPoint) then
                        -- 敌机被击中
                        u:byHit(v.attack)
                        if u.state == Enemy.E_STATE_INACTIVE then 
                            eBurn(u)
                        end
                        -- 玩家子弹命中，如果返回true，即子弹具有弹射技能
                        if v:byHit() then
                            if e then
                                v.targetTag = e:getTag()
                            end
                        end
                        if v.state ~= B_STATE_ACTIVE then
                            break
                        end
                    end
                    index = index + 1
                end
            end
        end
        -- 奖励运动
        local eventDispatcher = rootLayer:getEventDispatcher()
        local event = cc.EventCustom:new("MainLayerUI")
        event.type = "diamond"
        for i, v in ipairs(rewardLayer:getChildren()) do
            if v.state ~= R_STATE_INACTIVE then                 
                --modify liuchao
                if player.state ~= P_STATE_BURN then                   
                    v:setTarget(pX, pY)
                else
                    v:setTarget()
                end
                v:run()
                if cc.rectIntersectsRect(v:getBoundingBox(), r) then
                    if v.type == R_STAR1 or v.type == R_STAR2 or v.type == R_STAR3 then
                        if v.type == R_STAR1 then
                            diamond = diamond + 10
                        elseif v.type == R_STAR2 then
                            diamond = diamond + 30
                        else
                            diamond = diamond + 100
                        end
                        event.data = diamond
                        eventDispatcher:dispatchEvent(event)
                        --播放获取钻石的音效
                        AudioUtil.playEffect(GAME_SOUND.GET_DIAMOND_EFFECT,false)
                    else
                        --由于在player:getReward(v.type)后player:getLevel()的最大值为4
                        --所以提前获取，判断是否到达暴走状态
                        local level = player:getLevel()
                        --碰撞道具动画
                        local function actTip(tipId)
                            local x = player:getPositionX()
                            local y = player:getPositionY()
                            if tipId == 1 then
                                local gl = display.newSprite("#baozou glow.png",x,y)
                                local sp1 = display.newSprite("#bao.png",x - 22,y)
                                local sp2 = display.newSprite("#zou.png",x + 22,y)
                                rootLayer:addChild(gl,100)
                                rootLayer:addChild(sp1,100)
                                rootLayer:addChild(sp2,100)
                                sp1:setScale(1.2)
                                sp2:setScale(1.2) 
                                gl:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),
                                    cc.FadeOut:create(0.2),cc.CallFunc:create(function()
                                        gl:removeFromParent(true) end)))
                                sp1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.8),
                                    cc.DelayTime:create(0.3),cc.Spawn:create(cc.ScaleTo:create(0.2,1.5),cc.FadeOut:create(0.2))
                                    ,cc.CallFunc:create(function() sp1:removeFromParent(true) end)))
                                sp2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.8),
                                    cc.DelayTime:create(0.3),cc.Spawn:create(cc.ScaleTo:create(0.2,1.5),cc.FadeOut:create(0.2))
                                    ,cc.CallFunc:create(function() sp2:removeFromParent(true) end)))
                            elseif tipId == 2 then
                                local gl = display.newSprite("#shengji glow.png",x,y - 35)
                                local sp1 = display.newSprite("#shengji.png",x - 33,y - 20)
                                local sp2 = display.newSprite("#zhuangbei.png",x + 33,y - 20)
                                rootLayer:addChild(gl,100)
                                rootLayer:addChild(sp1,100)
                                rootLayer:addChild(sp2,100)
                                sp1:setRotation(-30)
                                sp2:setRotation(30)
                                gl:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),
                                    cc.FadeOut:create(0.2),cc.CallFunc:create(function() gl:removeFromParent(true) end)
                                ))
                                sp1:runAction(
                                    cc.Sequence:create(
                                        cc.Spawn:create(cc.RotateTo:create(0.2,0),cc.MoveTo:create(0.2,cc.p(x - 33,y) )),
                                        cc.DelayTime:create(0.3),
                                        cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0,10)),cc.FadeOut:create(0.2)),
                                        cc.CallFunc:create(function() sp1:removeFromParent(true) end)
                                    ))
                                sp2:runAction(
                                    cc.Sequence:create(
                                        cc.Spawn:create(cc.RotateTo:create(0.2,0),cc.MoveTo:create(0.2,cc.p(x + 33,y) )),
                                        cc.DelayTime:create(0.3),
                                        cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0,10)),cc.FadeOut:create(0.2)),
                                        cc.CallFunc:create(function() sp2:removeFromParent(true) end)
                                    ))
                            elseif tipId == 3 then
                                local gl = display.newSprite("#green point.png",x,y)
                                local sp1 = display.newSprite("#shengming.png",x - 35,y)
                                local sp2 = display.newSprite("#huifu.png",x + 35,y)
                                rootLayer:addChild(gl,100)
                                rootLayer:addChild(sp1,100)
                                rootLayer:addChild(sp2,100)
                                gl:runAction(cc.Sequence:create(cc.FadeOut:create(0.2),
                                    cc.DelayTime:create(0.3),cc.FadeIn:create(0.2),cc.CallFunc:create(function()
                                        gl:removeFromParent(true) end)))
                                sp1:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),
                                    cc.DelayTime:create(0.3),cc.FadeOut:create(0.2)
                                    ,cc.CallFunc:create(function() sp1:removeFromParent(true) end)))
                                sp2:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),
                                    cc.DelayTime:create(0.3),cc.FadeOut:create(0.2)
                                    ,cc.CallFunc:create(function() sp2:removeFromParent(true) end)))
                            elseif tipId == 4 then
                                local gl = display.newSprite("#green point.png",x,y - 35)
                                --        local sp1 = display.newSprite("#guangneng.png",x - 68,y)
                                local sp2 = display.newSprite("#hudun.png",x + 68,y)
                                rootLayer:addChild(gl,100)
                                --        rootLayer:addChild(sp1,100)
                                rootLayer:addChild(sp2,100)
                                gl:runAction(cc.Sequence:create(cc.FadeIn:create(0.2),
                                    cc.FadeOut:create(0.2),cc.CallFunc:create(function() gl:removeFromParent(true) end)
                                ))
                                --                                sp1:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(30,0)),
                                --                                    cc.DelayTime:create(0.3),cc.ScaleTo:create(0.2,1,0)
                                --                                    ,cc.CallFunc:create(function() sp1:removeFromParent(true) end)))
                                sp2:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-68,0)),
                                    cc.DelayTime:create(0.3),cc.ScaleTo:create(0.2,1,0)
                                    ,cc.CallFunc:create(function() 
                                        sp2:removeFromParent(true) 
                                    end)))
                            end
                        end
                        if v.type == R_WEAPON_UP1 or v.type == R_WEAPON_UP2 then                           
                            if v.type == R_WEAPON_UP1 then
                                level = level + 1
                            else 
                                level = level + 2
                            end
                            if level > 4 then
                                actTip(1)

                                --暴走音效
                                AudioUtil.playEffect(GAME_SOUND.POWERFULL_EFFECT,false)  
                            else
                                actTip(2)
                                --升级音效 
                                AudioUtil.playEffect(GAME_SOUND.LEVEL_UP_EFFECT,false)
                            end
                        end
                        --加血道具或护盾音效
                        if v.type == R_HP_UP or v.type == R_PROTECT then
                            if v.type == R_HP_UP then
                                actTip(3)
                            elseif v.type == R_PROTECT then
                                actTip(4)
                            end
                            AudioUtil.playEffect(GAME_SOUND.REWARD_EFFECT,false)
                        end


                        player:getReward(v.type)
                    end
                    --modify liuchao
                    if player.state == P_STATE_ACTIVE or player.state == P_STATE_INVISIBLE or player.wjbaoqi:isVisible() then
                        v:hit()
                    end

                end
            end   
        end
        -- 玩家激光运算
        for i, v in pairs(player.laser) do
            local t = {}
            local r = v:getBox()
            for j, u in ipairs(eLayer:getChildren()) do
                if u.state == Enemy.E_STATE_ACTIVE and u:isVisible() and not u.unable then
                    local box = u:getBox()
                    if  cc.rectIntersectsRect(r, box) then
                        table.insert(t, {weapon = u, index = k, y = box.y})
                    end
                end
            end
            local length = 1140
            if #t > 0 then
                table.sort(t, function (a, b) return a.y < b.y end)
                t[1].weapon:byHit(v.attack)
                if t[1].weapon.state == Enemy.E_STATE_INACTIVE then
                    eBurn(t[1].weapon)
                end
                length = t[1].y - r.y
            end
            v:setLength(length)
            v:update()
        end
    end

    -- 移除
    local function remove()
        -- 移除敌机
        for i, v in ipairs(eLayer:getChildren()) do
            if v.state == Enemy.E_STATE_INACTIVE and v.isRemove then 
                if v.isBoss then
                    if not v.isFade then
                        v.isFade = true
                        v:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(3),
                                cc.CallFunc:create(function ()
                                    v.weapon.armature:runAction(
                                        cc.FadeOut:create(1.5)
                                    )
                                end),
                                cc.DelayTime:create(1.5),
                                cc.RemoveSelf:create()
                            )
                        )
                    end
                    --                    performWithDelay(v,function()
                    --                        eLayer:removeChild(v)
                    --                    end,5)
                else
                    eLayer:removeChild(v)
                end
            end
        end
        -- 移除子弹
        for i, v in ipairs(ebLayer:getChildren()) do
            if v.state == B_STATE_INACTIVE then
                ebLayer:removeChild(v)
            end
        end
        for i, v in ipairs(pbLayer:getChildren()) do
            if v.state == B_STATE_INACTIVE then
                pbLayer:removeChild(v)
            end
        end
        -- 移除奖励
        for i, v in ipairs(rewardLayer:getChildren()) do
            if v.state == R_STATE_INACTIVE then
                rewardLayer:removeChild(v)
            end
        end
    end

    --生成撞机怪
    local showRateTime = 0
    --4种曲线随机ID
    local ran
    --撞机ID
    local enemyId
    --是否开始生成团中撞机
    local ranFlag = false
    --一团撞机出现数量
    local sum
    local function newHitEnemy()
        local randomWave = D.getRWave(levelIndex)
        if randomWave == nil then
            return
        end
        local randomEnemy = randomWave["wave"..index]

        --小团飞机间隔1/3秒出现
        if randomEnemy ~= nil then
            if rtime % (randomEnemy.rate * 60) == 0 and rtime ~= 0 and isRWaveOver == false then
                ran = math.random(1,#randomEnemy)
                enemyId = randomEnemy[ran]["enemy"..ran]
                ranFlag = true
                sum = 0    
            end
            -- 20帧一只撞机 
            if showRateTime % 20 == 0 and showRateTime ~= 0 and ranFlag == true then
                if sum == randomEnemy[ran]["num"..ran] then
                    showRateTime = 0
                    return
                end
                local e
                if level[index].hpFactor then
                    e = Enemy.newEnemy(enemyId, 1, level[index].hpFactor, level[index].bulletAttackFactor * attackFactor)
                else
                    e = Enemy.newEnemy(enemyId, 1, 1, 1)
                end
                eLayer:addChild(e,100)
                e:setTag(-1)
                sum = sum + 1
            end
        end
        showRateTime = showRateTime + 1
        rtime = rtime + 1       
        --寻找是否波次结束
        local function findExist()
            for i,v in ipairs(eLayer:getChildren()) do
                if v:getTag() ~= -1 then
                    isRWaveOver = false
                    return
                end
            end
            isRWaveOver = true
            return true
        end
        findExist()
    end
    --撞机暂停贝塞尔曲线
    local function pauseHitPlane()
        for i,v in pairs(eLayer:getChildren()) do
            v:pause()
        end
    end
    --撞机恢复动作曲线
    local function resumeHitPlane()
        for i,v in pairs(eLayer:getChildren()) do
            v:resume()
        end
    end

    -- 游戏逻辑
    local function update()
        if pause or (player.state ==  P_STATE_INACTIVE and player.wjbaoqi:isVisible() == false) then
            return
        end
        if not isEnd then
            --生成随机撞机怪
            newHitEnemy()
        end
        -- 创建敌机
        createEnemies()
        -- 运动
        run()
        -- 移除
        remove()
    end
    -- 菜单功能
    --tip动画
    local function actTip(str)
        local sp = display.newSprite(str,player:getPositionX(),player:getPositionY())
        rootLayer:addChild(sp,100)
        sp:runAction(cc.Sequence:create(cc.MoveBy:create(1,cc.p(0,50)),cc.FadeOut:create(0.4),cc.CallFunc:create(function()
            sp:removeFromParent(true)
        end)))
    end
    local eventDispatcher = rootLayer:getEventDispatcher()
    local function onListener(event)
        if event.type == "pause" then
            pause = true
            pauseHitPlane()
        elseif event.type == "continue" then
            pause = false
            resumeHitPlane()
        elseif event.type == "cbtLife" then
            player:cbtLife()
            touch = false
            -- 无敌炸弹
        elseif event.type == "bomb" then
            AudioUtil.playEffect(GAME_SOUND.LIGHTBOOM_EFFECT,false)
            actTip("#xingkonghedan.png")
            if bb then
                return
            end
            bb = true
            enemyShoot = false
            local bbb = cc.Sprite:create()
            local animate1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("bb1"))
            local animate2 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("bb2"))
            local animate3 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("bb3"))
            bbb:runAction(
                cc.Sequence:create(
                    animate1,
                    animate2,
                    animate3,
                    cc.CallFunc:create(function ()
                        bb = false
                        enemyShoot = true
                    end),
                    cc.RemoveSelf:create()
                )
            )
            bbb:setPosition(display.cx, display.cy)
            bbb:setScale(4)
            rootLayer:addChild(bbb, 7)
            -- 测试必杀持续时间用的
            bbTime = 0

        elseif event.type == "shield" then
            AudioUtil.playEffect(GAME_SOUND.REWARD_EFFECT,false)
            actTip("#chaojihudu.png")
            player:getReward(R_PROTECT)
            player:setProtectTime(-5*60)

        elseif event.type == "clearEnemyAttack" then
            enemyShoot = false
            performWithDelay(rootLayer,function()
                enemyShoot = true
            end,1)
            -- 子弹消失
            for i, v in ipairs(ebLayer:getChildren()) do
                v:invisible()
            end
            --护盾消失音效
            AudioUtil.playEffect(GAME_SOUND.SHEILD_LOSE_EFFECT,false)
        elseif event.type == "dead" then
            if endlessShop.buqu > 0 then
                player:setWJBaoqi(true)
                player.wjbaoqi.dead = true
                player:runAction(
                    cc.MoveTo:create(0.5, cc.p(display.cx, display.cy))
                )
            else
                -- 结算
                MyApp:enterLoadingScene({
                    num = diamond,
                    reward = endlessShop.tianci * 0.5 + 1,
                    heroId = param.heroId,
                    isEndless = true,
                    toScene = "EndlessWinScene"
                })
            end
        end
    end
    local listener = cc.EventListenerCustom:create("MainLayer", onListener)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    local schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)

    local function onNodeEvent(event)
        if "exitTransitionStart" == event then
            eventDispatcher:removeEventListener(listener)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
            DataUser:flushJson()
        end
    end
    rootLayer:registerScriptHandler(onNodeEvent)

    self:addChild(rootLayer)
end

-- 生成奖励

-- 生成敌机

function EndlessLayer:onUpdate(dt)

end

return EndlessLayer
