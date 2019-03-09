local ShowLayer = class("ShowLayer",function()
	return cc.Layer:create()
end)

function ShowLayer:ctor()
	local dataUser = require("tables.dataUser")
	local dataUi = require("tables.dataUi")

	local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.SHOW_LAYER_UI)  
	self:addChild(ui)
	 
	--1返回  2一星  3二星  4三星  5左箭头  6右箭头  7min/max 8开启
	local btn = {
		[1] = ui:getChildByName("Button_61"),
		[2] = ui:getChildByName("Button_63"),
		[3] = ui:getChildByName("Button_63_0"),
		[4] = ui:getChildByName("Button_63_1"),
		[5] = ui:getChildByName("Button_21"),
		[6] = ui:getChildByName("Button_21_0"),
		[7] = ui:getChildByName("Button_81"),
		[8] = ui:getChildByName("Button_17_1"),
	}
	
	--1获取条件 2条件  3一星  4二星  5三星  6等级 7等级数值  8攻击力 9生命值  10内容文本上  11内容文本下
	local lbl = {
		[1] = ui:getChildByName("Label_36"),
		[2] = ui:getChildByName("Label_36"):getChildByName("Label_36_1"),
		[3] = ui:getChildByName("Button_63"):getChildByName("Label_70"),
		[4] = ui:getChildByName("Button_63_0"):getChildByName("Label_70"),
		[5] = ui:getChildByName("Button_63_1"):getChildByName("Label_70"),
		[6] = ui:getChildByName("Image_80"):getChildByName("Label_84"),
--        [7] = ui:getChildByName("Image_80"):getChildByName("Label_85"),
		[8] = ui:getChildByName("Image_25"):getChildByName("Label_72"),
		[9] = ui:getChildByName("Image_41"):getChildByName("Label_73"),
		[10] = ui:getChildByName("Label_87"),
		[11] = ui:getChildByName("Image_86"):getChildByName("Label_88"),
	}
	
	--1max  2min  3战斗力  4-6人物名字  7光  8已拥有
	local img = {
		[1] = ui:getChildByName("Button_81"):getChildByName("Image_82"),
		[2] = ui:getChildByName("Button_81"):getChildByName("Image_83"),
		[3] = ui:getChildByName("Image_4"):getChildByName("Image_18"),
		[4] = ui:getChildByName("Image_86"):getChildByName("Image_47_1"),
		[5] = ui:getChildByName("Image_86"):getChildByName("Image_47"),
		[6] = ui:getChildByName("Image_86"):getChildByName("Image_47_0"),
		[7] = ui:getChildByName("Image_7_0"),
		[8] = ui:getChildByName("Image_125"),
		[9] = btn[8]:getChildByName("Image_18"),
		[10] = btn[8]:getChildByName("Image_19"),
		[11] = btn[8]:getChildByName("Image_19_0"),
	}
	
	--10个星星
	local star = {
		[1] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_5"),
		[2] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_6"),
		[3] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_3"),
		[4] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_7"),
		[5] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_2"),
		[6] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1_4"),
		[7] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0_1"),
		[8] = ui:getChildByName("Image_42_0"):getChildByName("Image_42"),
		[9] = ui:getChildByName("Image_42_0"):getChildByName("Image_42_0"),
		[10] = ui:getChildByName("Image_42_0"),
	}
	
	local function btnUp()
		img[9]:setVisible(true)
		img[10]:setVisible(true)
		img[11]:setVisible(false)
	end
	btnUp()
	local function btnDown()
		img[9]:setVisible(false)
		img[10]:setVisible(false)
		img[11]:setVisible(true)
	end
	
	--英雄ID
	local heroId = 1
	--英雄的名字
	local name = {LANGUAGE_CHINESE.IndexLayer[1],LANGUAGE_CHINESE.IndexLayer[2],LANGUAGE_CHINESE.IndexLayer[3]}
	--养成存档
	local heroData = dataUser.getHero()
	--英雄显示星级
	local heroStar = 1
	--是否最小等级
	local isMinLevel = true
	--自动切换演示
	local flag_i = 1
	--爆气效果
	local baoqi
	
	btn[2]:setBrightStyle(1)
	img[1]:setVisible(true)
	img[2]:setVisible(false)
	lbl[11]:setVisible(false)
--    lbl[2]:setVisible(false)
	   
	local armature
	--播放动画几次后暂停2秒
	local actTime = 0
	--老骨骼文件
	local oldName
	--更新状态显示
	local function showHero()
		local str
		if heroId == 1 then
			str = "bjt"..flag_i
		elseif heroId == 2 then
			str = "sunwukong"..flag_i
		elseif heroId == 3 then
			str = "sunjita"..flag_i
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
		local n = (heroId - 1) * 3 + flag_i
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
		armature:setPosition(display.cx + a,btn[5]:getPositionY() + b)
		
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
	img[7]:addChild(circle,-1)
	
	--爆气效果
	local function newAnimateBaoqi()
		if baoqi then
			baoqi:removeFromParent(true)
		end
		local heroData = dataUser.getHero()
		baoqi = cc.Sprite:create()
		if heroStar == 7 or heroStar == 1 then
			baoqi:setPosition(armature:getPositionX() + 10,armature:getPositionY() + 140)
		else
			baoqi:setPosition(armature:getPositionX() + 10,armature:getPositionY() + 100)
		end
		if heroStar == 7 or heroStar == 6 or heroStar == 2 then
			baoqi:setOpacity(180)
		end 
		baoqi:setScale(2)
		local tb = {}
		for i = 0,8 do
			table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("baoqi_"..heroStar.." ("..i..").png"))
		end
		local animation = cc.Animation:createWithSpriteFrames(tb,0.08)
		local animte = cc.Animate:create(animation)
		baoqi:runAction(cc.RepeatForever:create(animte))
		--    return sp
		self:addChild(baoqi,2)
	end
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
			if v.name == name and v["attack"..heroStar] then
				if maxLevel < v.level then
					maxLevel = v.level
				end
			end
		end
		return maxLevel
	end
	
	--根据名字和星级找最小等级
	local function findHeroMinLevel(name)
		local t = dataUi.getConsolidate()
		local minLevel = 100
		for i,v in pairs(t) do
			if v.name == name and v["attack"..heroStar] then
				if minLevel > v.level and v.conditionStar == heroStar then
					minLevel = v.level
				end
			end
		end
		return minLevel
	end
	
	local starNode
	--展示星级
	local function showStar()
		for i = 1,10 do
			star[i]:setOpacity(0)
		end

		if starNode then
			starNode:removeFromParent(true)
		end
		starNode = cc.Node:create()
		for i = 1,heroStar do
			local star = cc.Sprite:createWithSpriteFrameName("zjmStar.png")
			star:setPosition((i-1)*30,0)
			starNode:addChild(star)
		end
		starNode:setPosition(display.width/2 - (heroStar - 1)/2*30,star[10]:getPositionY())
		ui:addChild(starNode)
	end
	showStar()
	
	--切换星级
	local function setStar()
		if heroId == 1 then
			heroStar = flag_i
		elseif heroId == 2 then
			heroStar = flag_i + 1
		elseif heroId == 3 then
			heroStar = flag_i + 4
		end
	end
	
	local function showBuyInfo()
		if heroData[heroId].isHave == true and heroData[heroId].star >= heroStar then
			img[8]:setVisible(true)
			btn[8]:setVisible(false)
			lbl[1]:setVisible(false)
		elseif heroData[heroId].isHave == false and heroStar == heroData[heroId].star then
			img[8]:setVisible(false)
			btn[8]:setVisible(true)
			lbl[1]:setVisible(false)
		else
			img[8]:setVisible(false)
			btn[8]:setVisible(false)
			lbl[1]:setVisible(true)

			lbl[2]:setString((heroStar-1)..LANGUAGE_CHINESE.ShowLayer[6]..name[heroId])
		end
	end
	
	--更新文本信息
	local function showInfo()
		setStar()
		
		local p_level
		if isMinLevel == true then
		--    p_level = findHeroMinLevel(name[heroId])
			p_level = 0
			if p_level == 0 then
				p_level = 0
			end
			lbl[6]:setString(LANGUAGE_CHINESE.ShowLayer[5]..(p_level+1).."/"..findHeroMaxLevel(name[heroId]) + 1)
		else
			p_level = findHeroMaxLevel(name[heroId])
			lbl[6]:setString(LANGUAGE_CHINESE.ShowLayer[5]..(p_level+1).."/"..findHeroMaxLevel(name[heroId]) + 1)
		end
		lbl[6]:setColor(GAME_COLOR[heroStar])

		local data = findHeroConsolidateTable(p_level,name[heroId])
		
		lbl[8]:setString(data["attack"..heroStar])
		lbl[9]:setString(data["life"..heroStar])
		lbl[10]:setString(LANGUAGE_CHINESE.ShowLayer[heroId])

		for i = 1,3 do
			lbl[i+2]:setString(string.format(LANGUAGE_CHINESE.ShowLayer[4],heroStar - flag_i + i))
		end
		showStar()
		
		for i = 1,3 do
			if i == heroId then
				img[i + 3]:setVisible(true)
			else
				img[i + 3]:setVisible(false)
			end
		end
		
		local attack = data["attack"..heroStar]
		local life = data["life"..heroStar]
		--战斗力数值（数字0-9为碎图而非字体文件，做碎图处理）
		img[3]:removeAllChildren(true)
		local num = tostring((attack + life / 5) * 5)
		local len = num:len()
		for i = 1,len do
			local imgString = num:sub(i,i)
			local sp = cc.Sprite:createWithSpriteFrameName("shuzi"..imgString..".png")
			sp:setPosition(img[3]:getContentSize().width + 20 * i,img[3]:getContentSize().height / 2)
			img[3]:addChild(sp)
		end
		
		local heroData = dataUser.getHero()

		showBuyInfo()
	end
	showInfo()
	
	--切换星级按钮状态
	local function setBtnStyle(n)
		for i = 2,4 do
			if i - 1 == n then
				btn[i]:setBrightStyle(1)
			else
				btn[i]:setBrightStyle(0)
			end
		end
	end 
	
	--切换动画和文本信息
	local function changeHeroState()
		setBtnStyle(flag_i)
		showInfo()
		showHero()
		newAnimateBaoqi()
	end
	--每隔一段时间变换英雄状态
	local function changeStar()
		flag_i = flag_i + 1
		if flag_i > 3 then
			flag_i = 1
		end
		changeHeroState()
	end
	schedule(self,changeStar,3)
	
	for i = 1,8 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then   
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				--改变按钮状态
				if i == 1 then
					MyApp:enterIndexScene()
				elseif i >= 2 and i <= 4 then
					flag_i = i - 1
					changeHeroState()
					self:stopAllActions()
					newAnimateBaoqi()
				elseif i == 5 then
					heroId = heroId - 1
					if heroId < 1 then
						heroId = 3
					end
					showInfo()
					showHero()
					newAnimateBaoqi()
				elseif i == 6 then
					heroId = heroId + 1
					if heroId > 3 then
						heroId = 1
					end
					showInfo()
					showHero()
					newAnimateBaoqi()
				elseif i == 7 then
					if isMinLevel == true then
						isMinLevel = false
						img[1]:setVisible(false)
						img[2]:setVisible(true)
					else
						isMinLevel = true
						img[2]:setVisible(false)
						img[1]:setVisible(true)
					end
					showInfo()
				elseif i == 8 then
					local param = {heroId = heroId}
					btnUp()
					MyApp:enterIndexScene(param) 
				end
			elseif type == ccui.TouchEventType.began then
				if i == 8 then
					btnDown()
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	local eventDispatcher = self:getEventDispatcher()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local kListener = cc.EventListenerKeyboard:create()
		kListener:registerScriptHandler(function(keyCode, event)
			if IS_GUIDING then
				return
			end
			
			if keyCode == 6 then
				MyApp:enterIndexScene()
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED )
		eventDispatcher:addEventListenerWithSceneGraphPriority(kListener, self)
	end
end

return ShowLayer