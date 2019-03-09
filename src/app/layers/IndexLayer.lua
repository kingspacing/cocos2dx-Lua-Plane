local IndexLayer = class("IndexLayer",function()
	return cc.Layer:create()
end)

function IndexLayer:ctor(param)
	local dataUser = require("tables.dataUser")
	local dataUi = require("tables.dataUi")
	local GiftLayer = require("app.layers.GiftLayer")
	local ServiceLayer = require("app.layers.ServiceLayer")
	local Toast = require("app.layers.Toast")
	local PubDialog = require("app.layers.PubDialog")
	local GuideLayer = require("app.layers.GuideLayer")
	local RewardLayer = require("app.layers.RewardLayer")
	
	local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.INDEX_LAYER_UI)
	self:addChild(ui)
	
	IS_GUIDING = false
	
	--1强化  2进阶  3左箭头  4右箭头  5礼包  6音乐  7冒险  8电话  9-11选择角色 12-13 范围按钮  14幸运转盘
	local btn = {
		[1] = ui:getChildByName("Button_66"),
		[2] = ui:getChildByName("Button_66_0"),
		[3] = ui:getChildByName("Button_21"),
		[4] = ui:getChildByName("Button_21_0"),
		[5] = ui:getChildByName("Image_23"):getChildByName("Button_22"),
		[6] = ui:getChildByName("Button_17"),
		[7] = ui:getChildByName("Button_8"),
		[8] = ui:getChildByName("Button_17_0"),
		[9] = ui:getChildByName("Panel_65"):getChildByName("Button_33"),
		[10] = ui:getChildByName("Panel_65"):getChildByName("Button_33_0"),
		[11] = ui:getChildByName("Panel_65"):getChildByName("Button_33_1"),
		[12] = ui:getChildByName("Button_36"),
		[13] = ui:getChildByName("Button_36_0"),
		[14] = ui:getChildByName("Button_52"),
	}
	--1攻击力  2生命值  3-5角色和等级  6强化消耗  7进阶消耗  8龙珠加成
	local lbl = {
		[1] = ui:getChildByName("Image_25"):getChildByName("Label_72"),
		[2] = ui:getChildByName("Image_41"):getChildByName("Label_73"),
		[3] = btn[9]:getChildByName("Image_37"):getChildByName("Label_38"),
		[4] = btn[10]:getChildByName("Image_37"):getChildByName("Label_38"),
		[5] = btn[11]:getChildByName("Image_37"):getChildByName("Label_38"),
		[6] = btn[1]:getChildByName("Image_68"):getChildByName("Label_69"),
		[7] = btn[2]:getChildByName("Image_68"):getChildByName("Label_69"),
		[8] = ui:getChildByName("Label_52"),
	}
	--1一级强化  2二星进阶  3战斗力  4音量开  5音量开press  6音量关  7电话  8电话press  9-11选择角色 12按钮后的黄光  13礼包光效
	local img = {
		[1] = btn[1]:getChildByName("Image_67"),
		[2] = btn[2]:getChildByName("Image_67"),
		[3] = ui:getChildByName("Image_4"):getChildByName("Image_18"),
		[4] = ui:getChildByName("Button_17"):getChildByName("Image_28"),
		[5] = ui:getChildByName("Button_17"):getChildByName("Image_17"),
		[6] = ui:getChildByName("Button_17"):getChildByName("Image_64"),
		[7] = ui:getChildByName("Image_19"),
		[8] = ui:getChildByName("Image_20"),
		--1-3不同星级头像  4锁  5框  6-8人物名字
		[9] = {
			[1] = btn[9]:getChildByName("Image_34"),
			[2] = btn[9]:getChildByName("Image_35"),
			[3] = btn[9]:getChildByName("Image_36"),
			[4] = btn[9]:getChildByName("Image_39"),
			[5] = btn[9]:getChildByName("Image_37"),
			[6] = btn[9]:getChildByName("Image_37"):getChildByName("Image_44"),
			[7] = btn[9]:getChildByName("Image_37"):getChildByName("Image_44_0"),
			[8] = btn[9]:getChildByName("Image_37"):getChildByName("Image_44_0_1"),
		},
		[10] = {
			[1] = btn[10]:getChildByName("Image_34"),
			[2] = btn[10]:getChildByName("Image_35"),
			[3] = btn[10]:getChildByName("Image_36"),
			[4] = btn[10]:getChildByName("Image_39"),
			[5] = btn[10]:getChildByName("Image_37"),
			[6] = btn[10]:getChildByName("Image_37"):getChildByName("Image_45"),
			[7] = btn[10]:getChildByName("Image_37"):getChildByName("Image_45_0"),
			[8] = btn[10]:getChildByName("Image_37"):getChildByName("Image_45_0_1"),
		},
		[11] = {
			[1] = btn[11]:getChildByName("Image_34"),
			[2] = btn[11]:getChildByName("Image_35"),
			[3] = btn[11]:getChildByName("Image_36"),
			[4] = btn[11]:getChildByName("Image_39"),
			[5] = btn[11]:getChildByName("Image_37"),
			[6] = btn[11]:getChildByName("Image_37"):getChildByName("Image_43"),
			[7] = btn[11]:getChildByName("Image_37"):getChildByName("Image_43_0"),
			[8] = btn[11]:getChildByName("Image_37"):getChildByName("Image_43_0_1"),
		},
		[12] = ui:getChildByName("Image_23"),
		[13] = ui:getChildByName("Image_23_0"),
		[14] = ui:getChildByName("Image_7_0"),
		[15] = btn[1]:getChildByName("Image_68"):getChildByName("Image_42"),
		[16] = btn[2]:getChildByName("Image_68"):getChildByName("Image_43"),
	}
	--10个星星
	local star = {
		[1] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_5"),
		[2] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_6"),
		[3] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_3"),
		[4] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_7"),
		[6] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_4"),
		[8] = ui:getChildByName("Image_42_0"):getChildByName("Image_42"),
		[10] = ui:getChildByName("Image_42_0"), 
	}
	
	local isTouch = true
	
	--初始化某些控件
	img[5]:setVisible(false)
	img[6]:setVisible(false)
	img[8]:setVisible(false)
	lbl[8]:setVisible(false)
	for i = 9,11 do
		for j = 1,3 do
			img[i][j]:setScale(0.8)
		end
	end
	--弹礼包
	local function initGift()
		--礼包逻辑
		local gift = dataUser.getGift()
		if gift.onceIn == true and gift.initGift == false and gift.buyTime < 3 then
			self:getParent():addChild(GiftLayer.new(), 20)
			gift.onceIn = false
			dataUser.flushJson()
		end
	end
	if cc.UserDefault:getInstance():getBoolForKey("GUIDE_1", false) and
	cc.UserDefault:getInstance():getBoolForKey("GUIDE_4", false) and
	cc.UserDefault:getInstance():getBoolForKey("GUIDE_5", false) then
--        performWithDelay(self,initGift,0.02)
	end
	
	img[12]:setOpacity(0)
	img[13]:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,360)))
	btn[5]:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.ScaleTo:create(1,1.1),
		cc.ScaleTo:create(1,0.9)
		)))
		
	img[1]:setPositionY(img[1]:getPositionY() - 15)
	img[2]:setPositionY(img[2]:getPositionY() - 15)
	img[1]:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,20)),
		cc.FadeTo:create(1,100)),
		cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,-20)),cc.FadeTo:create(1,255)))
	))
	img[2]:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,20)),
		cc.FadeTo:create(1,100)),
		cc.Spawn:create(cc.MoveBy:create(1,cc.p(0,-20)),cc.FadeTo:create(1,255)))
	))
	
	btn[14]:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.ScaleTo:create(1,0.9),
		cc.ScaleTo:create(1,0.7)
	)))
	
	--礼包星星
	local function newGiftStar(px,py)
		local starAni = cc.Sprite:createWithSpriteFrameName("zjmlibaoS.png")
		starAni:setScale(0)
		starAni:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.5,1.5),
			cc.ScaleTo:create(0.5,0)
		))
		starAni:setPosition(px,py)
		img[12]:addChild(starAni,10)
	end
	
	--光圈效果
	local function newCircle()
		local sp = cc.Sprite:create()
		local tb = {}
		for i = 2,3 do
			table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("zjmzhantai"..i..".png"))
		end
		local animation = cc.Animation:createWithSpriteFrames(tb,0.1)
		sp:runAction(cc.RepeatForever:create(
			cc.Animate:create(animation)
		))
		sp:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.MoveBy:create(1,cc.p(0,10)),
			cc.MoveBy:create(1,cc.p(0,-10))
		)))
		return sp
	end
	local circle = newCircle()
	circle:setPosition(240,35)
	img[14]:addChild(circle,-1)
	
	--礼包星星
	local time = 0
	local function update()
		if time == 120 then
			time = 0
		end
		if time%20 == 0 then
			local randX = btn[5]:getPositionX()
			local randY = btn[5]:getPositionY()
			newGiftStar(math.random(randX - 80,randX + 80),math.random(randY - 80,randY + 80))
		end
		time = time + 1
	end
	self:scheduleUpdateWithPriorityLua(update,0) 
	
	local isMusic = AudioUtil.isBgm
	local dispatcher = self:getEventDispatcher()
	--英雄ID
	local heroId = 1
	--英雄的名字
	local name = {LANGUAGE_CHINESE.IndexLayer[1],LANGUAGE_CHINESE.IndexLayer[2],LANGUAGE_CHINESE.IndexLayer[3]}
	--英雄战斗力
	local battle
	--爆气效果
	local baoqi
	
	local function getStarState(id)
		local heroData = dataUser.getHero()
		local state
		if id == 1 then
			state = heroData[id].star
		elseif id == 2 then
			state = heroData[id].star - 1
		elseif id == 3 then
			state = heroData[id].star - 4
		end
		return state
	end
	
	local btnSelect
	local function changeBtnState()
		local heroData = dataUser.getHero()
		for i = 9,11 do
			--锁和变暗
			if heroData[i-8].isHave == false then
				btn[i]:setColor(cc.c3b(60,60,60))
				img[i][4]:setVisible(true)
				img[i][5]:setVisible(false)
				for j = 1,3 do
					img[i][j]:setColor(cc.c3b(60,60,60))
				end
			else
				btn[i]:setColor(cc.c3b(255,255,255))
				img[i][4]:setVisible(false)
				img[i][5]:setVisible(true)
				for j = 1,3 do
					img[i][j]:setColor(cc.c3b(255,255,255))
				end
			end
			--人物头像
			for j = 1,3 do
				if heroId == i-8 then
					if getStarState(heroId) == j then
						img[i][j]:setVisible(true)
						img[i][j+5]:setVisible(true)
					else
						img[i][j]:setVisible(false)
						img[i][j+5]:setVisible(false)
					end
				else
					if getStarState(i - 8) == j then
						img[i][j]:setVisible(true)
						img[i][j+5]:setVisible(true)
					else
						img[i][j]:setVisible(false)
						img[i][j+5]:setVisible(false)
					end
				end
			end
		end
		
		for i = 9,11 do
			if i == heroId + 8 then
				btn[i]:setScale(1)
				if btnSelect then
					btnSelect:removeFromParent(true)
				end
				btnSelect = cc.Sprite:createWithSpriteFrameName("zjmPic91.png")
				btnSelect:setPosition(btn[i]:getContentSize().width/2,btn[i]:getContentSize().height/2)
				btn[i]:addChild(btnSelect,-1)
			else
				btn[i]:setScale(0.8)
			end
		end
		
	end
	changeBtnState()
	
	local armature
	local actTime = 0
	local oldName   
	
	--强化，进阶
	local isActBtn1 = false
	local isActBtn2 = false    
	--强化效果
	local function newAnimateConsolidate(callback)
		local sp = cc.Sprite:create()
		sp:setPosition(armature:getPositionX(),armature:getPositionY() + 50)
		
		if GAME_RES.CURRENT == GAME_RES.HD then
			sp:setScale(5 / 3)
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			sp:setScale(5 / 3 * 2)
		end
		
		local tb = {}
		for i = 1,4 do
			table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("consolidate_"..i..".png"))
		end
		local animation = cc.Animation:createWithSpriteFrames(tb,0.1)
		sp:runAction(cc.Sequence:create(
			cc.Repeat:create(cc.Animate:create(animation),2),
			cc.CallFunc:create(function() callback() isActBtn1 = false isActBtn2 = false sp:removeFromParent(true) end)
		))
		return sp
	end
	--进阶效果
	local function newAnimateUpgrade(callback)
		local sp = cc.Sprite:create()
		sp:setPosition(armature:getPositionX(),armature:getPositionY() + 50)
		
		if GAME_RES.CURRENT == GAME_RES.HD then
			sp:setScale(5 / 3)
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			sp:setScale(5 / 3 * 2)
		end
		
		local tb = {}
		for i = 1,8 do
			table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("upgrade_"..i..".png"))
		end
		local animation = cc.Animation:createWithSpriteFrames(tb,0.13)
		sp:runAction(cc.Sequence:create(
			cc.Animate:create(animation),
			cc.CallFunc:create(function() isActBtn2 = false isActBtn1 = false sp:removeFromParent(true) end)
		))
		performWithDelay(self,callback,1.1)
		return sp
	end
	--爆气效果
	local function newAnimateBaoqi()
		if baoqi then
			baoqi:removeFromParent(true)
		end
		local heroData = dataUser.getHero()
		baoqi = cc.Sprite:create()
		   
		if GAME_RES.CURRENT == GAME_RES.HD then
			if heroData[heroId].star == 7 or heroData[heroId].star == 1 then
				baoqi:setPosition(armature:getPositionX() + 10,armature:getPositionY() + 140)
			else
				baoqi:setPosition(armature:getPositionX() + 10,armature:getPositionY() + 100)
			end
		
			if heroData[heroId].star == 7 or heroData[heroId].star == 6 or heroData[heroId].star == 2 then
				baoqi:setOpacity(180)
			end
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			baoqi:setPosition(armature:getPositionX() + 10,armature:getPositionY() + 100)
		end
		
		baoqi:setScale(2)
		local tb = {}
		
		if GAME_RES.CURRENT == GAME_RES.HD then
			for i = 0,8 do
				table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi_"..heroData[heroId].star.." ("..i..").png"))
			end
		elseif GAME_RES.CURRENT == GAME_RES.LD then
			for i = 1,4 do
				table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi_5 ("..(i*2-1)..").png"))
			end
		end
		
		
		local animation = cc.Animation:createWithSpriteFrames(tb,0.08)
		local animte = cc.Animate:create(animation)
		baoqi:runAction(cc.RepeatForever:create(animte))
		self:addChild(baoqi,2)
	end
	
	local function showHero()
		local heroStar = getStarState(heroId)
		if heroStar > 3 then
			heroStar = 3
		end
		local str
		if heroId == 1 then
			str = "bjt"..heroStar
		elseif heroId == 2 then
			str = "sunwukong"..heroStar
		elseif heroId == 3 then
			str = "sunjita"..heroStar
		end
		if armature ~= nil then
			armature:removeFromParent(true)
			actTime = 0
		end
		if oldName ~= nil then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(oldName)
		end
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/"..str..".ExportJson")
		oldName = "armatures/"..str..".ExportJson"
		armature = ccs.Armature:create(str)
		--设置位置
		local n = (heroId - 1) * 3 + heroStar
		local a
		local b
		if n == 1 then
			a,b = -10,-45
		elseif n == 2 then
			a,b = -10,-35
		elseif n == 3 then
			a,b = 0,-30
		elseif n == 4 then
			a,b = -10,-30
		elseif n == 5 then
			a,b = -10,-30
		elseif n == 6 then
			a,b = -10,-10
		elseif n == 7 then
			a,b = -10,-35
		elseif n == 8 then
			a,b = -10,-30
		elseif n == 9 then
			a,b = -10,-35
		end
		armature:setPosition(display.cx + a,btn[3]:getPositionY() + b)
		
		armature:setScale(0.9)
		self:addChild(armature,1)
		armature:getAnimation():playWithIndex(0)
		
		armature:getAnimation():setMovementEventCallFunc(
			function (arm, eventType, movmentID)
				if eventType == ccs.MovementEventType.complete then 
					actTime = actTime + 1
					if actTime == 1 or actTime == 0 then
						armature:getAnimation():playWithIndex(0)
					elseif actTime == 2 then
						performWithDelay(armature,function()
							armature:getAnimation():playWithIndex(0)
							actTime = 0
						end,2)
					end
				end
			end)
	end
	showHero()
	newAnimateBaoqi()
	
	--根据等级和名称查养成表
	local function findHeroConsolidateTable(level,name)
		local data
		local t = dataUi.getConsolidate()
		local maxLevel = 1
		for i,v in pairs(t) do
			if v.level == level and v.name == name then
				data = v
			end
			if v.name == name then
				if maxLevel < v.level then
					maxLevel = v.level
				end
			end
		end
		return data
	end
	--根据名字找最大等级
	local function findHeroMaxLevel(name)
		local t = dataUi.getConsolidate()
		local maxLevel = 1
		for i,v in pairs(t) do
			if v.name == name then
				if maxLevel < v.level then
					maxLevel = v.level
				end
			end
		end
		return maxLevel
	end
	--根据名字找最大星级
	local function findHeroMaxStar(name)
		local t = dataUi.getUpgrade()
		local maxStar = 1
		for i,v in pairs(t) do
			if v.name == name then
				if maxStar < v.advancedStar then
					maxStar = v.advancedStar
				end
			end
		end
		return maxStar
	end
	--根据名字和星星数找进阶表
	local function findHeroUpgradeTable(name,star)
		local table
		local t = dataUi.getUpgrade()
		for i,v in pairs(t) do
			if v.name == name and star == v.advancedStar - 1 then
				table = v
			end
		end
		return table
	end
	--是否找当前存档中人物是否已到当前星级最大等级
	local function findConsolidateMax()
		local h = dataUser.getHero()
		local c = dataUi.getConsolidate()
		local level = h[heroId].level
		local star = h[heroId].star
		local maxLevel = 0
		for i,v in pairs(c) do
			if v.conditionStar == star then
				if maxLevel < v.level then
					maxLevel = v.level
				end
			end
		end
		if level == maxLevel then
			return true
		else
			return false
		end   
	end
	
	--展示文本信息
	local function showInfo()
		local heroData = dataUser.getHero()
		local data = findHeroConsolidateTable(heroData[heroId].level,name[heroId])
		
		local attack = data["attack"..heroData[heroId].star]
		local life = data["life"..heroData[heroId].star]
		
		local dataUser = require("tables.dataUser")
		
		attack = math.floor(attack * dataUser.getAttack())
		life = math.floor(life * dataUser.getLife())
		
		lbl[1]:setString(attack)
		lbl[2]:setString(life)
		
		local strAttack = ""
		local strLife = ""
		if dataUser.getAttack() ~= 1 then
			strAttack = "攻击加成"..((dataUser.getAttack() - 1) * 100).."%"
		end
		if dataUser.getLife() ~= 1 then
			strLife = "生命加成"..((dataUser.getLife() - 1) * 100).."%"
		end
		
		if strAttack ~= "" or strLife ~= "" then
			lbl[8]:setVisible(true)
			lbl[8]:setString("龙珠激活属性:"..strAttack.." "..strLife)
		end
		
		local function getConditionLevel(id)
			local conditionLevel
			if id == 1 then
				conditionLevel = heroData[id].star * 5
			elseif id == 2 then
				conditionLevel = (heroData[id].star - 1) * 7
			elseif id == 3 then
				conditionLevel = (heroData[id].star - 4) * 9
			end
			return conditionLevel
		end
		
		for i = 1,3 do
			if heroData[i].level >= 1 then
				lbl[i + 2]:setString("Lv."..(heroData[i].level+1).."/"..getConditionLevel(i)+1)
			else
				lbl[i + 2]:setString("Lv."..(heroData[i].level+1).."/"..getConditionLevel(i)+1)
			end
		end
		
		for i = 1,3 do
			lbl[i + 2]:setColor(GAME_COLOR[heroData[i].star])
		end
		
		local t = findHeroConsolidateTable(heroData[heroId].level + 1,name[heroId])
		if findConsolidateMax() == false and t ~= nil then
			lbl[6]:setPositionX(80)
			lbl[6]:setString(t.conditionGold)
			img[15]:setVisible(true)
		else
			lbl[6]:setPositionX(70)
			lbl[6]:setString("MAX")
			img[15]:setVisible(false)
		end
		
		local t = findHeroUpgradeTable(name[heroId],heroData[heroId].star)
		if t ~= nil then
			lbl[7]:setPositionX(80)
			lbl[7]:setString(t.gold)
			img[16]:setVisible(true)
		else
			lbl[7]:setPositionX(70)
			lbl[7]:setString("MAX")
			img[16]:setVisible(false)
		end
		--战斗力数值（数字0-9为碎图而非字体文件，做碎图处理）
		img[3]:removeAllChildren(true)
		battle = (attack + life / 5) * 5
		local num = tostring(battle)
		local len = num:len()
		for i = 1,len do
			local imgString = num:sub(i,i)
			local sp = cc.Sprite:createWithSpriteFrameName("shuzi"..imgString..".png")
			sp:setPosition(img[3]:getContentSize().width + 20 * i,img[3]:getContentSize().height / 2)
			img[3]:addChild(sp)
		end
	end
	
	local starNode
	--展示星级
	local function showStar()
		local heroData = dataUser.getHero()
		for i,v in pairs(star) do
			star[i]:setOpacity(0)
		end
		
		if starNode then
			starNode:removeFromParent(true)
		end
		starNode = cc.Node:create()
		for i = 1,heroData[heroId].star do
			local star = cc.Sprite:createWithSpriteFrameName("zjmStar.png")
			star:setPosition((i-1)*30,0)
			starNode:addChild(star)
		end
		starNode:setPosition(display.width/2 - (heroData[heroId].star - 1)/2*30,star[10]:getPositionY())
		ui:addChild(starNode)
	end
	
	showInfo()
	showStar()

	local function freshGold()
		self:getParent():getChildByName("TopLayer"):fresh()
	end
	
	--刷新音乐开关
	local function refresh()
		if isMusic == false then
			img[4]:setVisible(false)
			img[5]:setVisible(true)
			img[6]:setVisible(true)
		else
			img[4]:setVisible(true)
			img[5]:setVisible(false)
			img[6]:setVisible(false)
		end
	end
	refresh()
	
	--根据所需金币获取，计费点，应得金币，剩余金币,赠送金币
	local function getGold(conditionGold)
		for i = 1,5 do
			if i == 1 then
				local t = dataUi.getRecharge(i)
				if conditionGold <= t.gold + t.giftGold then
					return 1,(t.gold + t.giftGold),(t.gold + t.giftGold - conditionGold),t.giftGold
				end
			else
				local t1 = dataUi.getRecharge(i - 1)
				local t2 = dataUi.getRecharge(i)
				if conditionGold > t1.gold + t1.giftGold and conditionGold <= t2.gold + t2.giftGold then
					return i,(t2.gold + t2.giftGold),(t2.gold + t2.giftGold - conditionGold),t2.giftGold
				end
			end
		end
	end
	
	local function showAddBattle()
		local heroData = dataUser.getHero()
		local data = findHeroConsolidateTable(heroData[heroId].level,name[heroId])
		local attack = data["attack"..heroData[heroId].star]
		local life = data["life"..heroData[heroId].star]
		local newBattle = (attack + life / 5) * 5
		
		local label = cc.Label:createWithBMFont("font/font5.fnt", "战斗力+"..newBattle - battle)
		label:setPosition(display.cx, display.cy + 20)
		self:addChild(label, 60)
		label:runAction(cc.Sequence:create({
			cc.MoveBy:create(1, cc.p(0, 80)),
			cc.RemoveSelf:create()
		}))
	end
	
	local function onBtn1()
		if isActBtn1 or isActBtn2 then
			return
		end
		local heroData = dataUser.getHero()
		if heroData[heroId].level == findHeroMaxLevel(name[heroId]) then
			Toast:show(LANGUAGE_CHINESE.IndexLayer[4])
			return
		end
		local t = findHeroConsolidateTable(heroData[heroId].level + 1,name[heroId])
		
		local function upData(n)
			heroData[heroId].level = heroData[heroId].level + 1
			dataUser.increaseGold(n)
			local taskData = dataUser.getTask()
			taskData.task4.consolidate = taskData.task4.consolidate + 1
			dataUser.flushJson()
		end
		
		--成功回调
		local function callback()
			showAddBattle()
			freshGold()
			showInfo()
			
			print("友盟强化")
			MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_CON_LEVEL, heroData[heroId].level))
		end
		
		if heroData[heroId].star >= t.conditionStar then
			if dataUser.getGold() >= t.conditionGold or IS_GUIDING then
				isActBtn1 = true
				
				if IS_GUIDING then
					t.conditionGold = 0
				end
				upData(-t.conditionGold)
				
				if GAME_RES.CURRENT == GAME_RES.HD then
					self:addChild(newAnimateConsolidate(function() callback() end),2)
				elseif GAME_RES.CURRENT == GAME_RES.LD then
					self:addChild(newAnimateUpgrade(function() callback() end),2)
				end

				AudioUtil.playEffect(GAME_SOUND.CONSOLIDATE_EFFECT,false)
			else
				local p1,p2,p3 = getGold(t.conditionGold)
				
				--最新的计费点为30块钱
				local dataUser = require("tables.dataUser")
				local recharge5 = dataUi.getRecharge(5)
				local rechargeGold = recharge5.gold + recharge5.giftGold - t.conditionGold
				
				local param = {dialogId = 3,rechargeGold = p2,handler = function()
					--以前参数为p3
					upData(rechargeGold)
					
					if GAME_RES.CURRENT == GAME_RES.HD then
						self:addChild(newAnimateConsolidate(function() callback() end),2)
					elseif GAME_RES.CURRENT == GAME_RES.LD then
						self:addChild(newAnimateUpgrade(function() callback() end),2)
					end
					
					isActBtn1 = true
				end,buyGold = t.conditionGold,finalGold = p3}
				self:getParent():addChild(PubDialog:newGoldDialog(param),10)
			end
		else
			Toast:show(string.format(LANGUAGE_CHINESE.IndexLayer[5],t.conditionStar))
		end
	end

	local function onBtn2()
		if isActBtn2 or isActBtn1 then
			return
		end
		local heroData = dataUser.getHero()
		if heroData[heroId].star == findHeroMaxStar(name[heroId]) then
			Toast:show(LANGUAGE_CHINESE.IndexLayer[7])
			return
		end
		local t = findHeroUpgradeTable(name[heroId],heroData[heroId].star)
		
		local function upData(n)
			heroData[heroId].star = heroData[heroId].star + 1
			local taskData = dataUser.getTask()
			if n < 0 then
				dataUser.increaseGold(n)
			end
			taskData.task5.upgrade = taskData.task5.upgrade + 1
			dataUser.flushJson()
		end
		
		--成功回调
		local function callback()
			showAddBattle()
			
			freshGold()
			showStar()
			showHero()
			showInfo()
			changeBtnState()
			newAnimateBaoqi()
			
			print("友盟进阶")
			MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_UPGRADE_STAR,heroData[heroId].star))            
		end
		if dataUser.getGold() >= t.gold or IS_GUIDING then
			isActBtn2 = true

			if IS_GUIDING then
				t.gold = 0
			end
			upData(-t.gold)
			self:addChild(newAnimateUpgrade(function() callback() end),2)

			AudioUtil.playEffect(GAME_SOUND.UPGRADE_EFFECT,false)
		else
			local p1,p2,p3,p4 = getGold(t.gold)
			local param = {dialogId = 4,heroId = heroId,rechargeGold = p2,handler = 
				function()
					upData(p3)
					self:addChild(newAnimateUpgrade(function() callback() 
						end),2)
					isActBtn2 = true
				end,buyGold = t.gold,finalGold = p4}
			self:getParent():addChild(PubDialog:newGoldDialog(param),10)
		end
	end
	
	local function onBtn6()
		if isMusic == true then
			img[4]:setVisible(false)
			img[5]:setVisible(true)
			img[6]:setVisible(true)
			isMusic = false
			
			AudioUtil.muteBGMusic()
			AudioUtil.muteEffect()
		else
			img[4]:setVisible(true)
			img[5]:setVisible(false)
			img[6]:setVisible(false)
			isMusic = true
			
			AudioUtil.openBGMusic()
			AudioUtil.openEffect()
			
			AudioUtil.playBGMusic(GAME_SOUND.MENU_BG,true) 
		end
	end
	
	local function onBtn8()
		img[7]:setVisible(true)
		img[8]:setVisible(false)
		self:getParent():addChild(ServiceLayer.new(),10)
	end
	
	local pCenter = btn[9]:getPositionX()
	btn[9].position = "center"
	btn[9].toPosition = "center"
	local pRight = btn[10]:getPositionX()
	btn[10].position = "right"
	btn[10].toPosition = "right"
	local pLeft = btn[11]:getPositionX()
	btn[11].position = "left"
	btn[11].toPosition = "left"
	local pY = btn[9]:getPositionY()
	
	--选择人物按钮平移
	local function changePosition(id)
		if btn[id].position == "left" then
			btn[id].toPosition = "center"
			btn[id]:runAction(cc.MoveTo:create(0.2,cc.p(pCenter,pY)))
			for i = 9,11 do
				if btn[i].position == "center" then
					btn[i].toPosition = "right"
					btn[i]:runAction(cc.MoveTo:create(0.2,cc.p(pRight,pY)))
				elseif btn[i].position == "right" then
					btn[i].toPosition = "left"
					btn[i]:runAction(cc.Sequence:create(
						cc.MoveTo:create(0.1,cc.p(display.width,pY)),
						cc.CallFunc:create(function() btn[i]:setPositionX(0) end),
						cc.MoveTo:create(0.1,cc.p(pLeft,pY))
					))
				end
			end
		elseif btn[id].position == "right" then
			btn[id].toPosition = "center"
			btn[id]:runAction(cc.MoveTo:create(0.2,cc.p(pCenter,pY)))
			for i = 9,11 do
				if btn[i].position == "center" then
					btn[i].toPosition = "left"
					btn[i]:runAction(cc.MoveTo:create(0.2,cc.p(pLeft,pY)))
				elseif btn[i].position == "left" then
					btn[i].toPosition = "right"
					btn[i]:runAction(cc.Sequence:create(
						cc.MoveTo:create(0.1,cc.p(0,pY)),
						cc.CallFunc:create(function() btn[i]:setPositionX(display.width) end),
						cc.MoveTo:create(0.1,cc.p(pRight,pY))
					))
				end
			end
		end
		for i = 9,11 do
			btn[i].position = btn[i].toPosition
		end
	end
	
	local function onBtn9(id)
		if isActBtn1 or isActBtn2 then
			return
		end
	
		local heroData = dataUser.getHero()
		local function handler()
			showInfo()
			showStar()
			showHero()
			changeBtnState()
			onBtn9(id)
		end
		print(id)
		if heroData[id].isHave == true then
			heroId = id
			showInfo()
			showStar()
			showHero()
			changeBtnState()
			changePosition(id + 8)
			
			dataUser.setHeroID(id)
			dataUser.flushJson()
		else
			self:getParent():addChild(PubDialog:newOpenHeroDialog(id,handler),10)
		end
		newAnimateBaoqi()
	end
	--默认人物
	local heroID = dataUser.getHeroID()
	onBtn9(heroID)
	
	for i = 1,14 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.began then
				if i == 6 then
					img[4]:setVisible(false)
					img[5]:setVisible(true)
				elseif i == 8 then
					img[7]:setVisible(false)
					img[8]:setVisible(true)   
				end
			elseif type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 or i == 12 then
					
					onBtn1()
					
					if IS_GUIDING then
						cc.UserDefault:getInstance():setBoolForKey("GUIDE_4", true)
						cc.UserDefault:getInstance():flush()
						self:getParent():removeChildByTag(GuideLayer.TAG)
						IS_GUIDING = false
					end
					
					local function showGuide()
						local function guide_6()
							local size = btn[2]:getContentSize()
							local pos = btn[2]:getWorldPosition()

							local guide = GuideLayer.new()
							guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
						end

						local function guide_5()
							local guide = GuideLayer.new()
							guide:show(self:getParent(), {mode = 1, msg = LANGUAGE_CHINESE.GUIDE[5],alignment = true, height = 130, isFree = true ,callback = function(sender, event) 
								sender:removeFromParent()
								guide_6()
							end})        
						end

						local GUIDE_5 = cc.UserDefault:getInstance():getBoolForKey("GUIDE_5", false)
						if GUIDE_5 == false then
							IS_GUIDING = true
							guide_5()
						end
					end
					showGuide()
				elseif i == 2 or i == 13 then
					onBtn2()
					if IS_GUIDING then
						cc.UserDefault:getInstance():setBoolForKey("GUIDE_5", true)
						cc.UserDefault:getInstance():flush()
						self:getParent():removeChildByTag(GuideLayer.TAG)
						IS_GUIDING = false
					end
				elseif i == 3 then
					MyApp:enterShowScene()
				elseif i == 4 then
					MyApp:enterShowScene()
				elseif i == 5 then
					self:getParent():addChild(GiftLayer.new())               
				elseif i == 6 then
					onBtn6()
				elseif i == 7 then
					if IS_GUIDING == true then
						IS_GUIDING = false
						self:getParent():removeChildByTag(GuideLayer.TAG)
						--友盟统计第3步
						MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_STEP,3))
						print("友盟统计第3步")
					end
					MyApp:enterLevelScene({heroId = heroId})
				elseif i == 8 then
					onBtn8()
				elseif i >= 9 and i <= 11 then
					onBtn9(i - 8)
				elseif i == 14 then
					self:getParent():addChild(RewardLayer.new({handler = showInfo}))
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	if param ~= nil and param.heroId ~= nil then
		performWithDelay(self,function() onBtn9(param.heroId) end,0.02)
	end
	
	local eventDispatcher = self:getEventDispatcher()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local kListener = cc.EventListenerKeyboard:create()
		kListener:registerScriptHandler(function(keyCode, event)
			if IS_GUIDING then
				return
			end
		
			if keyCode == 6 then
				MyApp:exit()
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED )
		eventDispatcher:addEventListenerWithSceneGraphPriority(kListener, self)
	end
	
	local function showGuide()
		local function guide_6()
			local size = btn[2]:getContentSize()
			local pos = btn[2]:getWorldPosition()

			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
		end

		local function guide_5()
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 1, msg = LANGUAGE_CHINESE.GUIDE[5],alignment = true, height = 130 , isFree = true ,callback = function(sender, event) 
				sender:removeFromParent()
				guide_6()
			end})        
		end


		local function guide_4()
			local size = btn[1]:getContentSize()
			local pos = btn[1]:getWorldPosition()

			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
		end

		local function guide_3()
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 1, msg = LANGUAGE_CHINESE.GUIDE[4], height = 130 ,alignment = true , isFree = true,callback = function(sender, event) 
				sender:removeFromParent()
				guide_4()
			end})        
		end

		local function guide_2()
			local size = btn[7]:getContentSize()
			local pos = btn[7]:getWorldPosition()

			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
		end

		local function guide_1()
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 1, msg = LANGUAGE_CHINESE.GUIDE[1], height = 140 ,callback = function(sender, event) 
				--友盟统计第二步
				MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_STEP, 2))
				print("友盟统计第2步")
				sender:removeFromParent()
				guide_2()
			end})        
		end
		
		local GUIDE_1 = cc.UserDefault:getInstance():getBoolForKey("GUIDE_1", false)
		if GUIDE_1 == false then
			IS_GUIDING = true
			guide_1()
			return
		end
		
		local GUIDE_4 = cc.UserDefault:getInstance():getBoolForKey("GUIDE_4", false)
		if GUIDE_4 == false then
			IS_GUIDING = true
			guide_3()
			return
		end
		
		local GUIDE_5 = cc.UserDefault:getInstance():getBoolForKey("GUIDE_5", false)
		if GUIDE_5 == false then
			IS_GUIDING = true
			guide_5()
			return
		end
	end
	
	performWithDelay(self, showGuide,0.02)

end

return IndexLayer

