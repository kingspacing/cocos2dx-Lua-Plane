require "app.sprites.Bullet"
require "app.sprites.Fire"
local Player =  require "tables.dataPlayer"
local Enemy = require "app.sprites.Enemy"
local Laser = require "app.sprites.Laser"
local User = require "tables.dataUser"
local dataUi = require("tables.dataUi")

-- 有效状态
P_STATE_ACTIVE = 1
-- 无效状态
P_STATE_INACTIVE = 2
-- 燃烧状态
P_STATE_BURN = 3
-- 隐身状态
P_STATE_INVISIBLE = 4
-- 子弹等级系数
local P_PERCENT = {
	1, 1.15, 1.3, 1.5, 3
}
-- 飞机缩放
local P_SCALE = 0.8
-- 僚机位置
local WINGMAN_X = 100
-- 蓄力缩放
local XULI_SCALE = {
	0.3, 0.4, 0.5, 0.6, 0.9
}

local tuozhan
if GAME_RES.CURRENT == GAME_RES.HD then
	tuozhan = "pvr.ccz"
elseif GAME_RES.CURRENT == GAME_RES.LD then
	tuozhan = "png"
end

-- 创建玩家
function createPlayer(enemyPower, heroId, extendPower)

	local sprite = cc.Sprite:create()
	sprite:setPosition(display.cx, display.cy / 2)
	
	-- 状态
	sprite.state = P_STATE_ACTIVE
	-- 武器等级状态
	local L = 1
	-- 计时器
	local time = 0
	
	--根据等级和名称查养成表
	local function findHero(level,name)
		local data
		local t = dataUi.getConsolidate()
		for i,v in pairs(t) do
			if v.level == level and v.name == name then
				data = v
			end
		end
		return data
	end
	local heroID = heroId
	local name
	if heroID == 1 then
		name = LANGUAGE_CHINESE.IndexLayer[1]
	elseif heroID == 2 then
		name = LANGUAGE_CHINESE.IndexLayer[2]
	elseif heroID == 3 then
		name = LANGUAGE_CHINESE.IndexLayer[3]
	end
	local heroData = User.getHero()[heroID]
	local d = findHero(heroData.level, LANGUAGE_CHINESE.IndexLayer[heroID])
	local playerData = {
		attack = d["attack"..heroData.star] * User.getAttack(),
		life = d["life"..heroData.star] * User.getLife(),
		id = nil,
	}
	local plane
	local protectScale = 1
	local armatureScale = 1
	
	-- 贝吉塔
	if heroID == 1 then
		if GAME_RES.CURRENT == GAME_RES.HD then
			if heroData.star == 1 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/beijita1.plist", "images/beijita1."..tuozhan)
			elseif heroData.star == 2 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/beijita2.plist", "images/beijita2."..tuozhan)
			elseif heroData.star == 3 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/beijita3.plist", "images/beijita3."..tuozhan)
			end
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			cc.SpriteFrameCache:getInstance():addSpriteFrames("images/beijita2.plist", "images/beijita2."..tuozhan)
		end    
		if heroData.star == 1 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/bjt1f0.png", "armatures/bjt1f0.plist", "armatures/bjt1f.ExportJson")
			plane = ccs.Armature:create("bjt1f")
			playerData.id = 1
			protectScale = 1.3
			armatureScale = 1.1
		elseif heroData.star == 2 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/bjt2f0.png", "armatures/bjt2f0.plist", "armatures/bjt2f.ExportJson")
			plane = ccs.Armature:create("bjt2f")
			playerData.id = 2
			protectScale = 1.3
			armatureScale = 1.1
		elseif heroData.star == 3 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/bjt3f0.png", "armatures/bjt3f0.plist", "armatures/bjt3f.ExportJson")
			plane = ccs.Armature:create("bjt3f")
			playerData.id = 3
			protectScale = 1.6
			armatureScale = 1.4
		end
	-- 孙悟空
	elseif heroID == 2 then
		if GAME_RES.CURRENT == GAME_RES.HD then
			print(heroData.star.."-------------")
			if heroData.star == 2 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/sunwukong1.plist", "images/sunwukong1."..tuozhan)
			elseif heroData.star == 3 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/sunwukong2.plist", "images/sunwukong2."..tuozhan)
			elseif heroData.star == 4 then
				for i,v in pairs(cc.FileUtils:getInstance():getSearchPaths()) do
					print(i,v)
				end
				
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/sunwukong3.plist", "images/sunwukong3."..tuozhan)
			end
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			cc.SpriteFrameCache:getInstance():addSpriteFrames("images/sunwukong2.plist", "images/sunwukong2."..tuozhan)
		end
		if heroData.star == 2 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wk1f0.png", "armatures/wk1f0.plist", "armatures/wk1f.ExportJson")
			plane = ccs.Armature:create("wk1f")
			playerData.id = 4
			protectScale = 1.4
			armatureScale = 1.1
		elseif heroData.star == 3 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wk2f0.png", "armatures/wk2f0.plist", "armatures/wk2f.ExportJson")
			plane = ccs.Armature:create("wk2f")
			playerData.id = 5
			protectScale = 1.4
			armatureScale = 1.1
		elseif heroData.star == 4 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wk3f0.png", "armatures/wk3f0.plist", "armatures/wk3f.ExportJson")
			plane = ccs.Armature:create("wk3f")
			playerData.id = 6
			protectScale = 1.3
			armatureScale = 1.1
		end
	-- 孙吉塔
	elseif heroID == 3 then
		if GAME_RES.CURRENT == GAME_RES.HD then
			if heroData.star == 5 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/wujita1.plist", "images/wujita1."..tuozhan)
			elseif heroData.star == 6 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/wujita2.plist", "images/wujita2."..tuozhan)
			elseif heroData.star == 7 then
				cc.SpriteFrameCache:getInstance():addSpriteFrames("images/wujita3.plist", "images/wujita3."..tuozhan)
			end
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			cc.SpriteFrameCache:getInstance():addSpriteFrames("images/wujita2.plist", "images/wujita2."..tuozhan)
		end
		if heroData.star == 5 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wb1f0.png", "armatures/wb1f0.plist", "armatures/wb1f.ExportJson")
			plane = ccs.Armature:create("wb1f")
			playerData.id = 7
			protectScale = 1.4
			armatureScale = 1.1
		elseif heroData.star == 6 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wb2f0.png", "armatures/wb2f0.plist", "armatures/wb2f.ExportJson")
			plane = ccs.Armature:create("wb2f")
			playerData.id = 8
			protectScale = 1.4
			armatureScale = 1.1
		elseif heroData.star == 7 then
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/wb3f0.png", "armatures/wb3f0.plist", "armatures/wb3f.ExportJson")
			plane = ccs.Armature:create("wb3f")
			playerData.id = 9
			protectScale = 1.4
			armatureScale = 1.1
		end
	end
	plane:getAnimation():setMovementEventCallFunc(
		function (arm, eventType, movmentID)
			if eventType == ccs.MovementEventType.complete and
				plane.id == 0 then
				plane.id = 1
				plane:getAnimation():playWithIndex(1)
		   elseif eventType == ccs.MovementEventType.complete and
				plane.id == 1 then
				plane.id = 0
				plane:getAnimation():playWithIndex(0)
			end
		end)
	plane:getAnimation():playWithIndex(0)
	plane.id = 0
	plane:setScale(P_SCALE, P_SCALE)
	sprite:addChild(plane)
	
	-- 暴走特效
	-- 暴气
	if GAME_RES.CURRENT == GAME_RES.HD then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/baoqi" .. heroData.star .. ".plist", "images/baoqi" .. heroData.star .. "."..tuozhan)
	elseif GAME_RES.CURRENT == GAME_RES.LD then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/baoqi5.plist", "images/baoqi5."..tuozhan)
	end
	
	local armature = cc.Sprite:create()
	armature:setVisible(false)
	armature:setScale(armatureScale)
	local spriteFrames = {}
	
	if GAME_RES.CURRENT == GAME_RES.HD then
		for i = 1, 4 do
			spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi" .. heroData.star .. "_" .. i .. ".png")
		end
	elseif GAME_RES.CURRENT == GAME_RES.LD then
		for i = 1, 4 do
			spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi5_" .. i .. ".png")
		end
	end
	
	local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
	armature:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
	armature.state = P_STATE_INACTIVE
	if heroData.star == 4 then
		armature:setPositionX(10)
	else
		armature:setPositionX(-5)
	end
	sprite:addChild(armature, 10)
	
	-- 无尽模式暴气
	cc.SpriteFrameCache:getInstance():addSpriteFrames("images/baoqi5.plist", "images/baoqi5."..tuozhan)
	local spriteFrames = {}
	for i = 1, 4 do
		spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi5_" .. i .. ".png")
	end
	local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
	sprite.wjbaoqi = cc.Sprite:create()
	sprite.wjbaoqi:setVisible(false)
	sprite.wjbaoqi:setPositionY(-200)
	sprite.wjbaoqi:setScale(1.5, 3)
	sprite.wjbaoqi:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
	sprite:addChild(sprite.wjbaoqi, 10)

	-- 计算战斗力系数
	local power = playerData.attack * 5 + playerData.life
	local attackFactor = 1
	-- 单发子弹攻击力计算
	local bodyWeaponSet = Player.getBody(playerData.id)
	function sprite:setAttackFactor(enemyPower)
		if enemyPower then
			attackFactor = (power - enemyPower) / 10000
			if attackFactor < -0.7 then
				attackFactor = -0.7
			elseif attackFactor > 0.3 then
				attackFactor = 0.3
			end
			attackFactor = 1 + attackFactor
		end
		
		if extendPower then
			attackFactor = attackFactor * extendPower
		end
		
		
		for i = 1, 5 do
			bodyWeaponSet[i].isPlayer = true
			local bulletQuantityMain = bodyWeaponSet[i].bulletQuantityMain
			local bulletQuantity = bodyWeaponSet[i].bulletQuantity
			if bulletQuantityMain ~= 0 and bulletQuantity == 0 then
				bodyWeaponSet[i].mainAttack = playerData.attack / bulletQuantityMain * P_PERCENT[i] * attackFactor
				bodyWeaponSet[i].attack = bodyWeaponSet[i].mainAttack
			elseif bulletQuantityMain == 0 and bulletQuantity ~= 0 then
				bodyWeaponSet[i].attack = playerData.attack / bulletQuantity * P_PERCENT[i] * attackFactor
				bodyWeaponSet[i].mainAttack = bodyWeaponSet[i].attack
			elseif bulletQuantityMain ~= 0 and bulletQuantity ~= 0 then
				bodyWeaponSet[i].mainAttack = playerData.attack / bulletQuantityMain * P_PERCENT[i] * attackFactor * 0.7
				bodyWeaponSet[i].attack = playerData.attack / bulletQuantity * P_PERCENT[i] * attackFactor * 0.3
			end
		end
	end
	sprite:setAttackFactor(enemyPower)
	
	-- 获取机体信息
	local bodyType = heroID
	
	-- 机体武器表
	-- 子弹攻击力计算
	for i, v in ipairs(bodyWeaponSet) do
		if v.laser then
			if v.laser.isMainLaser then
				v.laser.attack = bodyWeaponSet[i].mainAttack
			else
				v.laser.attack = bodyWeaponSet[i].attack
			end
		end
		-- 武器技能
	end
	-- 无敌炸弹1.5秒伤害
	sprite.bbAttack = power * 0.8 / 90
	
	local fx = 0
	local fxTime = 0
	
	-- 飞机大小
	sprite.w = 150
	sprite.h = 150
	-- 碰撞区域
	local hw = sprite.w * 0.2
	local hh = sprite.h * 0.2
	-- 亮点
	local pot = cc.Sprite:create()
	local animation = cc.AnimationCache:getInstance():getAnimation("pot")
	if not animation then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("images/pot.plist", "images/pot.pvr.ccz")
		local t = {cc.SpriteFrameCache:getInstance():getSpriteFrame("pot_1.png"),
			cc.SpriteFrameCache:getInstance():getSpriteFrame("pot_2.png")}
		animation = cc.Animation:createWithSpriteFrames(t, 0.05)
		cc.AnimationCache:getInstance():addAnimation(animation, "pot")
	end
	local animate = cc.Animate:create(animation)
	pot:runAction(cc.RepeatForever:create(animate))
	pot:setPosition(0, -5)
	sprite:addChild(pot)
	-- 护盾
	local protect = cc.Sprite:create()
	sprite.protect = protect
	-- 护盾计时器
	protect.time = 0
	protect:setVisible(false)
	local animation = cc.AnimationCache:getInstance():getAnimation("hudun")
	local animateProtect = cc.Animate:create(animation)
	protect:runAction(cc.RepeatForever:create(animateProtect))
	sprite:addChild(protect, 100)
	
	-- 血量
	local hp = playerData.life
	-- 血量
	sprite.hp = hp
	-- 碰撞攻击力，暂定为血量值
	sprite.attack = hp * attackFactor * 0.1
	
	-- 获取战斗力
	function sprite:getPower()
		return power
	end
	
	-- 激光，不是所有武器组合都具有激光
	sprite.laser = {
		-- 机体上面的激光
		body = nil,
	}
	
	function sprite:newLaser()
		if self.laser.body then
			self:removeChild(self.laser.body)
			self.laser.body = nil
		end
		
		if self.state == P_STATE_BURN then
			return
		end
		
		local n = L
		if armature.state == P_STATE_ACTIVE then
			n = 5
		end
		if bodyWeaponSet[n].laser then
			self.laser.body = Laser.newLaser(bodyWeaponSet[n].laser)
			self:addChild(self.laser.body, -1)
		end
		
		if self.wjbaoqi:isVisible() and self.laser.body then
			self.laser.body:setVisible(false)
		end
	end
	sprite:newLaser()
	
	-- 刷新血量条
	function sprite:freshHPBar()
		local eventDispatcher = self:getEventDispatcher()
		local event = cc.EventCustom:new("MainLayerUI")
		event.type = "playerHP"
		event.data = self.hp / hp * 100
		eventDispatcher:dispatchEvent(event)
	end
	
	-- 刷新暴走条
	function sprite:freshPowerBar()
		local eventDispatcher = self:getEventDispatcher()
		local event = cc.EventCustom:new("MainLayerUI")
		event.type = "powerBar"
		event.data = (1 - armature.time / 240) * 100 
		eventDispatcher:dispatchEvent(event)
	end
	
	-- 复活
	function sprite:cbtLife()
		plane:stopAllActions()
		-- 会满血
		self.hp = hp
		self:freshHPBar()
		-- 武器等级状态
		L = 1
		self:newLaser()
		plane:setScale(P_SCALE, P_SCALE)
		self:invisible()
		self:setPosition(display.cx, -200)
		self:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(display.cx, 200)), cc.CallFunc:create(function()
		   -- sprite.state = P_STATE_ACTIVE
		end)))
	end
	
	-- 暴走
	function sprite:powerful()
		armature:setVisible(true)
		if armature.state == P_STATE_INACTIVE then
			armature.state = P_STATE_ACTIVE
			self:newLaser()
		end
		armature.time = 0
	end

	function sprite:getReward(type)
		if self.state == P_STATE_INACTIVE or self.state == P_STATE_BURN then
			return
		end
		-- 武器等级提升
		if type == R_WEAPON_UP1 or type == R_WEAPON_UP2 then
			if type == R_WEAPON_UP1 then
				L = L + 1
			elseif type == R_WEAPON_UP2 then
				L = L + 2
			end
			-- 武器升级，超过4级暴走
			if L > 4 then
				L = 4
				self:powerful()
			end
			self:newLaser()
		-- 回血
		elseif type == R_HP_UP and not self.wjbaoqi:isVisible() then
			self.hp = self.hp + hp * 0.25
			if self.hp > hp then
				self.hp = hp
			end
			self:freshHPBar()
		-- 护盾
		elseif type == R_PROTECT and not self.wjbaoqi:isVisible() then
			if protect.time > 0 then 
				protect.time = 0
			end
			protect:stopAction(protect.scale)
			protect:setScale(protectScale)
			protect:setOpacity(255)
			protect:setVisible(true)
		end       
	end
	function sprite:setProtectTime(time)
		protect.time = time
	end
	function sprite:run()
		-- 处于燃烧或死亡状态，直接返回
		if self.state == P_STATE_BURN or self.state == P_STATE_INACTIVE then
			return
		-- 处于隐身状态1秒，并且屏幕显示抖动
		elseif self.state == P_STATE_INVISIBLE then
			if time == 60 then
				self.state = P_STATE_ACTIVE
				plane:setOpacity(255)
				armature:setOpacity(255)
				cc.Director:getInstance():getRunningScene():setPositionX(0)
			elseif time % 4 == 0 then
				cc.Director:getInstance():getRunningScene():setPositionX(-3)
			elseif time % 2 == 0 then
				cc.Director:getInstance():getRunningScene():setPositionX(3)
			end
			time = time + 1
		end
		
		if fx ~= 0 then 
			if fxTime <= 0 then 
				self:move(fx*2)
			else 
				fxTime = fxTime - 1
			end 
		end
		
		-- 处于暴走状态
		if armature.state == P_STATE_ACTIVE then
			-- 暴走5秒
			if armature.time == 240 then
				-- 暴走结束
				armature.state = P_STATE_INACTIVE
				armature:setVisible(false)
				self:newLaser()
			else
				armature.time = armature.time + 1
			end
			-- 刷新暴走条
			self:freshPowerBar()
		end
		-- 处于护盾状态
		if protect:isVisible() then
			-- 维持5秒
			if protect.time == 300 then
				protect:setVisible(false)
				protect:setScale(protectScale)
			elseif protect.time == 240 then
				protect:setOpacity(255)
				protect.scale = cc.ScaleTo:create(1, 30)
				protect:runAction(protect.scale)
				local eventDispatcher = self:getEventDispatcher()
				local event = cc.EventCustom:new("MainLayer")
				event.type = "clearEnemyAttack"
				eventDispatcher:dispatchEvent(event)
			elseif protect.time > 120 then
				if protect.time % 30 == 0 then
					protect:setOpacity(0)
				elseif protect.time % 15 == 0 then
					protect:setOpacity(255)
				end
			end
			protect.time = protect.time + 1
		end
	end

	-- 隐身
	function sprite:invisible()
		self.state = P_STATE_INVISIBLE
		plane:setOpacity(128)
		armature:setOpacity(128)
		time = 0
	end

	-- 被击中
	function sprite:byHit(attack)
		if self.state ~= P_STATE_ACTIVE or protect:isVisible() then
			return 0
		end
		self.hp = self.hp - attack
		-- 武器降级
		L = L - 1
		if L < 1 then
			L = 1
		end
		if self.hp <= 0 then
			self.hp = 0
			self:burn()
		else
			self:invisible()
		end
		-- 更新血量条
		self:freshHPBar()
		self:newLaser()
	end
	
	-- 燃烧
	function sprite:burn()
		self.state = P_STATE_BURN
		-- 如果武器中有激光，就把它们移除
		self:newLaser()

--        plane:setScale(P_SCALE, P_SCALE)
		
		plane:runAction(cc.Sequence:create(
			cc.CallFunc:create(function() 
				local an = cc.ParticleSystemQuad:create("particles/enemy_burn.plist")
				an:setPosition(self:getPositionX(), self:getPositionY())
				an:setAutoRemoveOnFinish(true)
				cc.Director:getInstance():getRunningScene():addChild(an, 10)
			end),
			cc.DelayTime:create(0.8),
			cc.CallFunc:create(function()
				plane:setScale(P_SCALE, P_SCALE)
				self.state = P_STATE_INACTIVE
			end)
		))
	end
	
	-- 开火
	function sprite:fire(tx, ty)
		if self.state == P_STATE_BURN or self.state == P_STATE_INACTIVE or self.wjbaoqi:isVisible() then
			return {}
		end
		local x = sprite:getPositionX()
		local y = sprite:getPositionY()
		if armature.state == P_STATE_ACTIVE then
			return {
						fire(bodyWeaponSet[5], x, y, tx, ty), -- 机体开火
				   }
		else
			return {
						fire(bodyWeaponSet[L], x, y, tx, ty), -- 机体开火
				   }
		end
	end
	-- 获取碰撞区域
	function sprite:getBox()
		local x = self:getPositionX()
		local y = self:getPositionY()
		if protect:isVisible() then
			return cc.rect(x - self.w / 2, y - self.h / 2, self.w, self.h)
		else
			return cc.rect(x - hw / 2, y - hh / 2, hw, hh)
		end
	end

	-- 演示使用的提升武器等级
	function sprite:setLevel(l)
		L = l
		self:newLaser()
	end
	
	function sprite:getLevel()
		return L
	end
	
	function sprite:setWJBaoqi(flag)
		print "qwerqwrwqrwq"
		if flag then
			sprite.wjbaoqi:setVisible(true)
			if sprite.laser.body then
				sprite.laser.body:setVisible(false)
			end
		else
			sprite.wjbaoqi:setVisible(false)
			if sprite.laser.body then
				sprite.laser.body:setVisible(true)
			end
		end
	end

	return sprite
end