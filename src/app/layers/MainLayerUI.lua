local MainLayerUI = class("MainLayerUI",function()
	return cc.Layer:create()
end)

function MainLayerUI:ctor(param)
	local dataUser = require("tables.dataUser")
	local GiftLayer = require("app.layers.GiftLayer")
	local ResultLayer= require("app.layers.ResultLayer")
	local PauseLayer = require("app.layers.PauseLayer")
	local PubDialog = require("app.layers.PubDialog")
	local Toast = require("app.layers.Toast")
	local dataLevel = require("tables.dataLevel")
	local GuideLayer = require("app.layers.GuideLayer")
	IS_GUIDING = false
	
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.MAIN_LAYER_UI)
	self:addChild(ui)
	
	--1暂停  2礼包  3核弹  4护盾
	local btn = {
		[1] = ui:getChildByName("Button_23"),
		[2] = ui:getChildByName("Button_15"),
		[3] = ui:getChildByName("Button_33"),
		[4] = ui:getChildByName("Button_4"),
	}
	--1BOSS名称  2血量  3核弹  4护盾  5分数
	local lbl = {
		[1] = ui:getChildByName("Label_25"),
		[2] = ui:getChildByName("Image_19"):getChildByName("Label_22"),
		[3] = ui:getChildByName("Button_33"):getChildByName("Image_6"):getChildByName("Label_7"),
		[4] = ui:getChildByName("Button_4"):getChildByName("Image_13"):getChildByName("Label_14"),
		[5] = ui:getChildByName("Label_22")
	}
	--1金币  2BOSS血条  3能量
	local img = {
		[1] = ui:getChildByName("Image_24"),
		[2] = ui:getChildByName("Image_19"),
		[3] = ui:getChildByName("Image_15"),
	}
	-- 1红条  2蓝条  3-6英雄血条 蓝黄橙红  4能量条
	local bar = {
		[1] = ui:getChildByName("ProgressBar_21_0"),
		[2] = ui:getChildByName("ProgressBar_21"),
		[3] = ui:getChildByName("Image_17"):getChildByName("ProgressBar_15_1"),
		[4] = ui:getChildByName("Image_17"):getChildByName("ProgressBar_15"),
		[5] = ui:getChildByName("Image_17"):getChildByName("ProgressBar_15_0"),
		[6] = ui:getChildByName("Image_17"):getChildByName("ProgressBar_15_2"),
		[7] = ui:getChildByName("Image_15"):getChildByName("Image_18"):getChildByName("ProgressBar_19"),
	}
	
	local yellowCircle = cc.Sprite:createWithSpriteFrameName("zjmlibaoD.png")
	yellowCircle:setPosition(btn[2]:getPosition())
	ui:addChild(yellowCircle)
	yellowCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,360)))
	
	btn[2]:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.ScaleTo:create(1,0.9),
		cc.ScaleTo:create(1,0.7)
	)))
	
	if param.isEndless == true then
		img[1]:setOpacity(0)
	else
		lbl[5]:setVisible(false)
	end
	
	--礼包星星
	local function newGiftStar(px,py)
		local starAni = cc.Sprite:createWithSpriteFrameName("zjmlibaoS.png")
		starAni:setScale(0)
		starAni:runAction(cc.Sequence:create(
			cc.ScaleTo:create(0.5,1.5),
			cc.ScaleTo:create(0.5,0)
		))
		starAni:setPosition(px,py)
		ui:addChild(starAni,10)
	end
	
	--礼包星星
	local time = 0
	local function update()
		if time == 120 then
			time = 0
		end
		if time%20 == 0 then
			local randX = btn[2]:getPositionX()
			local randY = btn[2]:getPositionY()
			newGiftStar(math.random(randX - 80,randX + 80),math.random(randY - 80,randY + 80))
		end
		time = time + 1
	end
	self:scheduleUpdateWithPriorityLua(update,0) 
	
	
	local dispatcher = self:getEventDispatcher()
	lbl[1]:setVisible(false)
	if param.id and dataLevel.getLevelInfo(param.id).bossInfo then
		lbl[1]:setString(dataLevel.getLevelInfo(param.id).bossInfo)
	end  
	img[2]:setVisible(false)
	bar[1]:setVisible(false)
	bar[2]:setVisible(false)
	img[3]:setVisible(false)
	
	local function showGold(gold)
		img[1]:removeAllChildren(true)
		--金币数值（数字0-9为碎图而非字体文件，做碎图处理）
		local num = tostring(gold)
		local len = num:len()
		for i = 1,len do
			local imgString = num:sub(i,i)
			local sp = cc.Sprite:createWithSpriteFrameName("shuzizhandou"..imgString..".png")
			sp:setPosition(img[1]:getContentSize().width + 27 * i,img[1]:getContentSize().height / 2)
			img[1]:addChild(sp)
		end
	end
	showGold(0)
	
	--显示物品并继续游戏
	local function showProp()
		local dataUser = require("tables.dataUser")
		lbl[3]:setString(dataUser.getBoom())
		lbl[4]:setString(dataUser.getShield())
		
		local event = cc.EventCustom:new("MainLayer")
		event.type = "continue"
		dispatcher:dispatchEvent(event)
	end
	showProp()
	--礼包按钮回调
	local function newGiftLayer()
		local param = {handler = showProp}
		self:addChild(GiftLayer.new(param))
		local event = cc.EventCustom:new("MainLayer")
		event.type = "pause"
		dispatcher:dispatchEvent(event)
	end
	--暂停回调
	local function pauseHandler()
		local dataUser = require("tables.dataUser")
		lbl[3]:setString(dataUser.getBoom())
		lbl[4]:setString(dataUser.getShield())
	end
	
	--炸弹冷却
	local canBoom = true
	local canShield = true
	for i = 1,4 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					local param = {isEndless = param.isEndless,handler = pauseHandler}
					self:addChild(PauseLayer.new(param))
					local event = cc.EventCustom:new("MainLayer")
					event.type = "pause"
					dispatcher:dispatchEvent(event)
				elseif i == 2 then
					newGiftLayer()
				elseif i == 3 then
					if canBoom == false then
						return
					end
					canBoom = false
					performWithDelay(self,function() canBoom = true end,1.5)
					
					if dataUser.getBoom() > 0 or IS_GUIDING then
						local event = cc.EventCustom:new("MainLayer")
						event.type = "bomb"
						dispatcher:dispatchEvent(event)
						dataUser.increaseBoom(-1)
						showProp()
						
						if IS_GUIDING then
							cc.UserDefault:getInstance():setBoolForKey("GUIDE_3", true)
							cc.UserDefault:getInstance():flush()
							IS_GUIDING = false
							self:getParent():removeChildByTag(GuideLayer.TAG)
						end
					else
						if dataUser.getGold() < 50000 then
							local param = {dialogId = 1,handler = showProp}
							self:addChild(PubDialog:newGoldDialog(param))
							local event = cc.EventCustom:new("MainLayer")
							event.type = "pause"
							dispatcher:dispatchEvent(event)
						else
							dataUser.increaseGold(-50000)
							dataUser.increaseBoom(10)
							dataUser.flushJson()
							Toast:show(LANGUAGE_CHINESE.MainLayerUI[1])
							showProp()
						end
					end
				elseif i == 4 then
					if canShield == false and dataUser.getShield() > 0 then
						return
					end
					
					if dataUser.getShield() > 0 or IS_GUIDING then
						local event = cc.EventCustom:new("MainLayer")
						event.type = "shield"
						dispatcher:dispatchEvent(event)
						dataUser.increaseShield(-1)
						showProp()
						canShield = false
						performWithDelay(self,function() canShield = true end,10)
						
						if IS_GUIDING then
							cc.UserDefault:getInstance():setBoolForKey("GUIDE_2", true)
							cc.UserDefault:getInstance():flush()
							IS_GUIDING = false
							self:getParent():removeChildByTag(GuideLayer.TAG)
						end
					else
						if dataUser.getGold() < 50000 then
							local param = {dialogId = 2,handler = showProp}
							self:addChild(PubDialog:newGoldDialog(param))
							local event = cc.EventCustom:new("MainLayer")
							event.type = "pause"
							dispatcher:dispatchEvent(event)
						else
							dataUser.increaseGold(-50000)
							dataUser.increaseShield(10)
							dataUser.flushJson()
							Toast:show(LANGUAGE_CHINESE.MainLayerUI[1])
							showProp()
						end
					end
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	--玩家血量 钻石
	local resultHp = 0
	local resultDiamond = 0
	--玩家血量
	local hp = 100
	local dataHp = 100
	
	local function showPlayerHp(hp)
		for i = 3,6 do
			bar[i]:setVisible(false)
		end
		if hp > 75 then
			bar[3]:setVisible(true)
			bar[3]:setPercent(hp)
		elseif hp > 50 then
			bar[4]:setVisible(true)
			bar[4]:setPercent(hp)
		elseif hp > 25 then
			bar[5]:setVisible(true)
			bar[5]:setPercent(hp)
		else
			bar[6]:setVisible(true)
			bar[6]:setPercent(hp)
		end
	end
	showPlayerHp(100)
	
	local function onListener(event)
		if event.type == "playerHP" then
			dataHp = math.floor(event.data)
			local function update()
				if dataHp == 100 then
					hp = 100
				end
				if hp > dataHp then                    
					hp = hp - 1  
				elseif hp < dataHp then  
					hp = hp + 1                 
				end
				showPlayerHp(hp)
			end
			self:scheduleUpdateWithPriorityLua(update,0)
			resultHp = event.data
		elseif event.type == "powerBar" then
			if event.data <= 0 then
				img[3]:setVisible(false)
			else
				img[3]:setVisible(true)
			end
			bar[7]:setPercent(event.data)
		elseif event.type == "bossHP_1" then
			if event.data <= 0 then
		 --       lbl[1]:setVisible(false)
				img[2]:setVisible(false)
				bar[1]:setVisible(false)
				bar[2]:setVisible(false)
			elseif event.data == 100 then
		 --       lbl[1]:setVisible(true)
				img[2]:setVisible(true)   
				bar[1]:setVisible(true)
				bar[2]:setVisible(true)
			end
			if param.isEndless == nil and dataLevel.getLevelInfo(param.id).bossInfo then
				lbl[2]:setString(dataLevel.getLevelInfo(param.id).bossInfo.." "..event.data.."%")
			else
				lbl[2]:setString(event.data.."%")
			end
			bar[1]:setPercent(event.data)
		elseif event.type == "bossHP_2" then
			if event.data <= 0 then
		  --      lbl[1]:setVisible(false)
				img[2]:setVisible(false)
				bar[1]:setVisible(false)
				bar[2]:setVisible(false)
			elseif event.data == 100 then
		 --       lbl[1]:setVisible(true)
				img[2]:setVisible(true)
				bar[1]:setVisible(false)
				bar[2]:setVisible(true)
			end
			if param.isEndless == nil and dataLevel.getLevelInfo(param.id).bossInfo then
				lbl[2]:setString(dataLevel.getLevelInfo(param.id).bossInfo.." "..event.data.."%")
			else
				lbl[2]:setString(event.data.."%")
			end
			bar[2]:setPercent(event.data)
		elseif event.type == "diamond" then
			showGold(event.data)
			resultDiamond = event.data
		elseif event.type == "dead" then
			local function endlessHandler()
				local event = cc.EventCustom:new("MainLayer")
				event.type = "dead"
				dispatcher:dispatchEvent(event)
			end
			self:addChild(PubDialog:newReliveDialog({id = param.id,event = event.data,heroId = param.heroId,isOverLimmit = param.isOverLimmit,handler1 = showProp,handler2 = endlessHandler}))
		elseif event.type == "gameEnd" then
		elseif event.type == "win" then
			self:addChild(ResultLayer:newWinLayer({hp = dataHp,id = param.id,gold = resultDiamond,killEnemy = event.data,isOverLimmit = param.isOverLimmit,heroId = param.heroId}))
		elseif event.type == "GUIDE_2" then
			local guide = GuideLayer.new()
			local size = btn[4]:getContentSize()
			local pos = btn[4]:getWorldPosition()
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})
			IS_GUIDING = true
		elseif event.type == "GUIDE_3" then
			local guide = GuideLayer.new()
			local size = btn[3]:getContentSize()
			local pos = btn[3]:getWorldPosition()
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})
			IS_GUIDING = true
		elseif event.type == "buyGift" then
			newGiftLayer()
		end
	end
	local listener = cc.EventListenerCustom:create("MainLayerUI", onListener)
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	
	local function onNodeEvent(event)
		if "exitTransitionStart" == event then
			dataUser.flushJson()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
	local eventDispatcher = self:getEventDispatcher()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local kListener = cc.EventListenerKeyboard:create()
		kListener:registerScriptHandler(function(keyCode, event)
			if IS_GUIDING then
				return
			end
			
			if keyCode == 6 then
				param.toScene = "LevelScene"
				MyApp:enterLoadingScene(param)
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED )
		eventDispatcher:addEventListenerWithSceneGraphPriority(kListener, self)
	end
	
	
	
end

return MainLayerUI
