local PubDialog = class("PubDialog")

function PubDialog:newReliveDialog(param)
	local dataUser = require("tables.dataUser")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PUB_DIALOG_RELIVE)
	layer:addChild(ui)
	
	--1关闭  2获取
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_16_0"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
	}
	--1发光  2正常  3press
	local img = {
		[1] = btn[2]:getChildByName("Image_27"),
		[2] = btn[2]:getChildByName("Image_87"),
		[3] = btn[2]:getChildByName("Image_87_0"),
	}
	--1.退出战斗  不保存进度  2是否确定退出
	local lbl = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Label_22"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Label_23"),
	}
	
	local dispatcher = layer:getEventDispatcher()
	
	local function btnUp()
		img[1]:setVisible(true)
		img[2]:setVisible(true)
		img[3]:setVisible(false)
	end
	btnUp()
	local function btnDown()
		img[1]:setVisible(false)
		img[2]:setVisible(false)
		img[3]:setVisible(true)
	end
	
	lbl[1]:setVisible(false)
	lbl[2]:setVisible(false)
	
	for i = 1,2 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					if param.event == nil then
						local ResultLayer = require("app.layers.ResultLayer")
						layer:getParent():addChild(ResultLayer:newLoseLayer(param))
					else
						param.handler2()
					end
					layer:removeFromParent(true)
				elseif i == 2 then
					MyApp:pay("pay12")
				end
			elseif type == ccui.TouchEventType.began then
				if i == 2 then
					btnDown()
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	local function paySuccessCallback(event)
		if event._usedata == "pay12" then
			dataUser.increaseShield(1)
			dataUser.increaseBoom(1)
			dataUser.flushJson()
			param.handler1()

			local event = cc.EventCustom:new("MainLayer")
			event.type = "cbtLife"
			dispatcher:dispatchEvent(event)
			btnUp()
			layer:removeFromParent(true)
		end
	end
	--监听付费点成功付费反馈
	local listener = cc.EventListenerCustom:create("pay_result", paySuccessCallback)
	local eventDispatcher = layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
	
	return layer
end

function PubDialog:newOpenHeroDialog(id,handler)
	local Toast = require("app.layers.Toast")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PUB_OPEN_HERO_UI)
	layer:addChild(ui)

	--1关闭  2开启 3黑色按钮
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_62"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_17"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Button_17_0"),
	}
	--1等级  2攻击  3.生命  4.战斗力  5.开启条件  6.+
	local lbl = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Label_61_0"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Label_20"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Label_20_0"),
		[4] = ui:getChildByName("Image_18"):getChildByName("Label_20_1"),
		[5] = ui:getChildByName("Image_18"):getChildByName("Image_32"):getChildByName("Label_33_0"),
		[6] = ui:getChildByName("Image_18"):getChildByName("Image_32"):getChildByName("Label_33_1"),
	}
	-- 1悟吉塔 2按钮状态  3-4人物左至右 5孙悟空
	local img = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Image_37"),
		[2] = {
			[1] = btn[2]:getChildByName("Image_18"),
			[2] = btn[2]:getChildByName("Image_19"),
			[3] = btn[2]:getChildByName("Image_19_0"),
		},
		[3] = ui:getChildByName("Image_18"):getChildByName("Image_32"):getChildByName("Image_36"),
		[4] = ui:getChildByName("Image_18"):getChildByName("Image_32"):getChildByName("Image_36_0"),
		[5]= ui:getChildByName("Image_18"):getChildByName("Image_41"),
	}
	
	local star = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Image_36"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Image_36_0"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Image_36_1"),
		[4] = ui:getChildByName("Image_18"):getChildByName("Image_36_2"),
		[5] = ui:getChildByName("Image_18"):getChildByName("Image_36_3"),
	}
	
	local function btnUp(id)
		img[id][1]:setVisible(true)
		img[id][2]:setVisible(true)
		img[id][3]:setVisible(false)
	end
	local function btnDown(id)
		img[id][1]:setVisible(false)
		img[id][2]:setVisible(false)
		img[id][3]:setVisible(true)
	end
	for i = 2,2 do
		btnUp(i)
	end

	local dispatcher = layer:getEventDispatcher()
	local dataUser = require("tables.dataUser")
	local dataUi = require("tables.dataUi")
	
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
	
	local function showStar(n)
		for i = 1,5 do
			if i <= n then
				star[i]:setVisible(true)
			else
				star[i]:setVisible(false)
			end
		end
	end
	
	--英雄的名字
	local name = {LANGUAGE_CHINESE.IndexLayer[1],LANGUAGE_CHINESE.IndexLayer[2],LANGUAGE_CHINESE.IndexLayer[3]}
	local heroData = dataUser.getHero()
	local data = findHeroConsolidateTable(heroData[id].level,name[id])

	local attack = data["attack"..heroData[id].star]
	local life = data["life"..heroData[id].star]
	lbl[2]:setString(attack)
	lbl[3]:setString(life)
	lbl[4]:setString((attack + life/5) * 5)
	
	if id == 2 then
		local panel = ui:getChildByName("Image_18"):getChildByName("Image_32")
		
		local text1 = ccui.Text:create(LANGUAGE_CHINESE.PubDialog[10],"Arial",18)
		text1:setPosition(panel:getContentSize().width/2 + 20,panel:getContentSize().height/2)
		text1:setColor(cc.c3b(0,210,255))
		panel:addChild(text1)
		
		local goldImg = cc.Sprite:createWithSpriteFrameName("zjiJinbi.png")
		goldImg:setPosition(panel:getContentSize().width/2 + 5,panel:getContentSize().height/2)
		goldImg:setScale(0.5)
		panel:addChild(goldImg)
		
		lbl[5]:setVisible(false)
		lbl[6]:setVisible(false)
		img[3]:setVisible(false)
		img[4]:setVisible(false)
		
		lbl[1]:setString("LV.1/8")
		lbl[1]:setColor(GAME_COLOR[2])
		img[1]:setVisible(false)
		img[5]:setVisible(true)
		showStar(2)
	elseif id == 3 then  
		local panel = ui:getChildByName("Image_18"):getChildByName("Image_32")

		local text1 = ccui.Text:create(LANGUAGE_CHINESE.PubDialog[11],"Arial",18)
		text1:setPosition(panel:getContentSize().width/2 + 20,panel:getContentSize().height/2)
		text1:setColor(cc.c3b(0,210,255))
		panel:addChild(text1)

		local goldImg = cc.Sprite:createWithSpriteFrameName("zjiJinbi.png")
		goldImg:setPosition(panel:getContentSize().width/2 + 5,panel:getContentSize().height/2)
		goldImg:setScale(0.5)
		panel:addChild(goldImg)

		lbl[5]:setVisible(false)
		lbl[6]:setVisible(false)
		img[3]:setVisible(false)
		img[4]:setVisible(false)

		lbl[1]:setString("LV.1/8")
		lbl[1]:setColor(GAME_COLOR[2])
		
		img[1]:setVisible(true)
		img[5]:setVisible(false)
		showStar(5)
	end

	local armature
	local actTime = 0
	local oldName
	local function showHero()
		local str
		if id == 1 then
			str = "bjt1"
		elseif id == 2 then
			str = "sunwukong1"
		elseif id == 3 then
			str = "sunjita1"
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
		
		local panel = ui:getChildByName("Image_18")
		
		armature:setPosition(panel:getContentSize().width / 4,panel:getContentSize().height / 4 * 3 - 50)
		armature:setScale(0.7)
		panel:addChild(armature,1)
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
	
	local function openHero()
		local heroData = dataUser.getHero()
		heroData[id].isHave = true
		dataUser.flushJson()
		handler() 
		layer:setVisible(false)
	end

	for i = 1,2 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				
				local param = {}
				param.dialogId = 3
				param.handler = function()
					local dataUser = require("tables.dataUser")
					local t = dataUi.getRecharge(5)
					if id == 2 then
--                        local rechargeGold = t.gold + t.giftGold - 30000
--                        dataUser.increaseGold(rechargeGold) 
					elseif id == 3 then
						local rechargeGold = t.gold + t.giftGold - 120000
						dataUser.increaseGold(rechargeGold)
					end
					dataUser.flushJson()
					layer:getParent():getChildByName("TopLayer"):fresh()
					openHero()
				end
				
				if i == 1 then
					layer:removeFromParent(true)
				elseif i == 2 then
					if id == 2 then
						btnUp(i)
						local level = dataUser.getLevel()
						if dataUser.getGold() >= 30000 then
							dataUser.increaseGold(-30000)
							layer:getParent():getChildByName("TopLayer"):fresh()
							openHero()
						else
							param.type = "openHero"
							layer:addChild(self:newGoldDialog(param))
						end
					elseif id == 3 then
						local heroData = dataUser.getHero()
						if dataUser.getGold() >= 120000 then
							dataUser.increaseGold(-120000)
							layer:getParent():getChildByName("TopLayer"):fresh()
							openHero()
						else
							layer:addChild(self:newGoldDialog(param))
						end
					end                   
				end   
			elseif type == ccui.TouchEventType.began then
				if i == 2 then
					btnDown(i)
				end  
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end

	return layer
end

function PubDialog:newBattleDialog(param)
	local GiftLayer = require("app.layers.GiftLayer")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PUB_BATTLE_UI)
	layer:addChild(ui)

	--1领取胶囊  2取消  3确定
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_30"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_17_0"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Button_17"),
	}
	--1发光  2正常  3press
	local img = {
		[1] = {
			[2] = btn[1]:getChildByName("Image_31_0"),
			[3] = btn[1]:getChildByName("Image_31"),
		},
		[2] = {
			[1] = btn[2]:getChildByName("Image_18"),
			[2] = btn[2]:getChildByName("Image_19"),
			[3] = btn[2]:getChildByName("Image_19_0"),
		},
		[3] = {
			[1] = btn[3]:getChildByName("Image_18"),
			[2] = btn[3]:getChildByName("Image_19"),
			[3] = btn[3]:getChildByName("Image_19_0"),
		},
	}

	local dispatcher = layer:getEventDispatcher()

	local function btnUp(id)
		if img[id][1] then
			img[id][1]:setVisible(true)
		end
		img[id][2]:setVisible(true)
		img[id][3]:setVisible(false)
	end
	
	local function btnDown(id)
		if img[id][1] then
			img[id][1]:setVisible(false)
		end
		img[id][2]:setVisible(false)
		img[id][3]:setVisible(true)
	end
	for i = 1,3 do
		btnUp(i)
	end

	for i = 1,3 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				btnUp(i)
				if i == 1 then
					layer:addChild(GiftLayer.new())
				elseif i == 2 then
					layer:removeFromParent(true)
				elseif i == 3 then
					MyApp:enterLoadingScene(param)
				end
			elseif type == ccui.TouchEventType.began then
				btnDown(i)
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end

	return layer
end

--dialogId:1炸弹不足 2护盾不足   3强化不足  4进阶不足
function PubDialog:newGoldDialog(param)
	local dataUser = require("tables.dataUser")
	local Toast = require("app.layers.Toast")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PUB_DIALOG_UI)
	layer:addChild(ui)

	--1-2关闭  3确定
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_22"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_16"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
	}
	--1白字  2红字 3返还 4数字
	local lbl = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Label_19"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Label_19_0"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Label_19_1"),
		[4] = ui:getChildByName("Image_18"):getChildByName("Label_36"),
	}
	--1反光  2立即购买  3立即进阶  4立即强化  5确定
	local img = {
		[1] = btn[3]:getChildByName("Image_27"),
		[2] = {
			[1] = btn[3]:getChildByName("Image_87"),
			[2] = btn[3]:getChildByName("Image_87_0"),
		},
		[3] = {
			[1] = btn[3]:getChildByName("Image_87_1"),
			[2] = btn[3]:getChildByName("Image_87_0_0"),
		},
		[4] = {
			[1] = btn[3]:getChildByName("Image_87_1_2"),
			[2] = btn[3]:getChildByName("Image_87_0_0_1"),
		},
		[5] = {
			[1] = btn[3]:getChildByName("Image_87_2"),
			[2] = btn[3]:getChildByName("Image_87_0_1"),
		},
		[6] = ui:getChildByName("Image_18"):getChildByName("Image_43"),
	}

	local dispatcher = layer:getEventDispatcher()
	
	btn[2]:setVisible(false)
	img[6]:setVisible(false)
	lbl[4]:setVisible(false)
	
	--1立即购买  2立即进阶  3立即强化  4确定
	local function showBtnUp(n)
		for i = 2,5 do
			img[i][1]:setVisible(false)
			img[i][2]:setVisible(false)
		end
		img[1]:setVisible(true)
		img[n+1][1]:setVisible(true)
		img[n+1][2]:setVisible(false)
	end
	local function showBtnDown(n)
		for i = 2,5 do
			img[i][1]:setVisible(false)
			img[i][2]:setVisible(false)
		end
		img[1]:setVisible(false)
		img[n+1][1]:setVisible(false)
		img[n+1][2]:setVisible(true)
	end
	
	if param.dialogId == 1 then
		lbl[1]:setString(LANGUAGE_CHINESE.PubDialog[2])
		lbl[2]:setString(LANGUAGE_CHINESE.PubDialog[3])
		lbl[3]:setVisible(false)
		showBtnUp(1)
	elseif param.dialogId == 2 then
		lbl[1]:setString(LANGUAGE_CHINESE.PubDialog[4])
		lbl[2]:setString(LANGUAGE_CHINESE.PubDialog[5])
		lbl[3]:setVisible(false)
		showBtnUp(1)
	elseif param.dialogId == 3 then  
		if param.type and param.type == "openHero" then
			lbl[1]:setString("您的金币不足30000")
			lbl[1]:setColor(cc.c3b(255,0,0))
			lbl[2]:setString("是否发送短信立即开启?")
			lbl[3]:setVisible(false)
			showBtnUp(4)
		else
			lbl[1]:setString(LANGUAGE_CHINESE.PubDialog[6])
			lbl[1]:setColor(cc.c3b(255,0,0))
			lbl[2]:setVisible(false)
			lbl[3]:setVisible(false)
			showBtnUp(1)
		end
	elseif param.dialogId == 4 then
		lbl[1]:setString(LANGUAGE_CHINESE.PubDialog[7]..param.buyGold)
	--    lbl[1]:setString("立即获得金币"..param.buyGold)
		lbl[1]:setColor(cc.c3b(255,0,0))
		lbl[2]:setString("是否发送短信立即进阶?")
--        lbl[3]:setString(LANGUAGE_CHINESE.PubDialog[8])
--        lbl[4]:setString(param.finalGold)
		lbl[3]:setVisible(false)
		lbl[4]:setVisible(false)
		showBtnUp(2)
		img[6]:setVisible(false)
	end

--    local function btnUp()
--        img[1]:setVisible(true)
--        img[2]:setVisible(true)
--        img[3]:setVisible(false)
--    end
--    btnUp()
--    local function btnDown()
--        img[1]:setVisible(false)
--        img[2]:setVisible(false)
--        img[3]:setVisible(true)
--    end
	local dataUi = require("tables.dataUi")
	
	for i = 1,3 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					if param.dialogId == 1 or param.dialogId == 2 then  
						param.handler()
					end
					layer:removeFromParent(true)
				elseif i == 2 then
					layer:removeFromParent(true)
				elseif i == 3 then
					if param.dialogId == 1 then   
						MyApp:pay("pay13")           
					elseif param.dialogId == 2 then
						MyApp:pay("pay14")
					elseif param.dialogId == 3 then
						showBtnUp(3)
						if param.type and param.type == "openHero" then
							MyApp:pay("pay15")
						else
							MyApp:pay("pay11")
						end
					elseif param.dialogId == 4 then
						showBtnUp(2)
--                        for j = 1,5 do
--                            local t = dataUi.getRecharge(j)
--                            if param.rechargeGold == t.gold + t.giftGold then
--                                MyApp:pay("pay"..j)
--                            end
--                        end
						local dataUser = require("tables.dataUser")
						local star = dataUser.getHero()[param.heroId].star
						print(param.heroId,star)
						if star == 2 then
							MyApp:pay("pay3")
						elseif star == 3 then
							MyApp:pay("pay4")
						elseif star == 5 then
							MyApp:pay("pay5")
						elseif star == 6 then
							MyApp:pay("pay6")
						elseif star == 1 then
							param.handler()
							layer:removeFromParent(true)
						end
					end
					
				end
			elseif type == ccui.TouchEventType.began then
				if i == 3 then
					if param.dialogId == 1 then
						showBtnDown(1)
					elseif param.dialogId == 2 then
						showBtnDown(1)
					elseif param.dialogId == 3 then
						if param.type and param.type == "openHero" then
							showBtnDown(4)
						else
							showBtnDown(1)
						end     
					elseif param.dialogId == 4 then
						showBtnDown(2)
					end
				end 
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	local function paySuccessCallback(event)
		if event._usedata == "pay7"
		or event._usedata == "pay8"
		or event._usedata == "pay9"
		or event._usedata == "pay10"
		or event._usedata == "pay11" then
			param.handler()
			layer:removeFromParent(true)
		elseif event._usedata == "pay1"
		or event._usedata == "pay3"
		or event._usedata == "pay4"
		or event._usedata == "pay5"
		or event._usedata == "pay6" then
			param.handler()
			layer:removeFromParent(true)
		elseif event._usedata == "pay13" then
			dataUser.increaseBoom(10)
			dataUser.flushJson()
			showBtnUp(1)
			Toast:show(LANGUAGE_CHINESE.PubDialog[9])
			param.handler()
			layer:removeFromParent(true)
		elseif event._usedata == "pay14" then
			dataUser.increaseShield(10)
			dataUser.flushJson()
			showBtnUp(1)
			Toast:show(LANGUAGE_CHINESE.PubDialog[9])
			param.handler()
			layer:removeFromParent(true)
		elseif event._usedata == "pay15" then
			param.handler()
			layer:removeFromParent(true)
		elseif event._usedata == "pay0" then
			if param.dialogId == 3 then
				MyApp:enterRechargeScene()
			end
		end
	end
	--监听付费点成功付费反馈
	local listener = cc.EventListenerCustom:create("pay_result", paySuccessCallback)
	local eventDispatcher = layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	return layer
end

function PubDialog.newBallDialog(param)
	local dataUi = require("tables.dataUi")
	local Toast = require("app.layers.Toast")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Cjtips.ExportJson")
	layer:addChild(ui)
	
	local panel = ui:getChildByName("Image_18")
	--1关闭  2激活
	local btn = {
		[1] = panel:getChildByName("Button_16"),
		[2] = panel:getChildByName("Button_26"),
	}
	--1-3上至下
	local lbl = {
		[1] = panel:getChildByName("Label_19"),
		[2] = panel:getChildByName("Label_19_0"),
		[3] = panel:getChildByName("Label_19_1"),
	}
	--1高光 2正常 3点击
	local img = {
		[1] = btn[2]:getChildByName("Image_26"),
		[2] = btn[2]:getChildByName("Image_87"),
		[3] = btn[2]:getChildByName("Image_87_0"),
	}
	
	local function btnDown()
		img[1]:setVisible(false)
		img[2]:setVisible(false)
		img[3]:setVisible(true)
	end
	local function btnUp()
		img[1]:setVisible(true)
		img[2]:setVisible(true)
		img[3]:setVisible(false)
	end
	btnUp()
	
	local data = dataUi.getBall(param.id)
	
	local lifeStr = ""
	local attackStr = ""
	if data.life ~= nil then
		lifeStr = data.life .. "%生命"
	end
	if data.attack ~= nil then
		attackStr = data.attack .. "%攻击"
	end
	
	lbl[1]:setString("提升战斗人物"..lifeStr..attackStr)
	lbl[2]:setString("龙珠激活属性可累加")
	lbl[3]:setString("激活需要"..data.payBall.."颗龙珠")
	
	for i = 1,2 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				if i == 1 then
					layer:removeFromParent(true)
				elseif i == 2 then
					btnUp()
					local dataUser = require("tables.dataUser")
					
					if dataUser.getBall() >= data.payBall then
						dataUser.increaseBall(-data.payBall)
						
						if data.life ~= nil then
							dataUser.setLife(dataUser.getLife()+data.life/100)
						end
						if data.attack ~= nil then
							dataUser.setAttack(dataUser.getAttack()+data.attack/100)
						end
						Toast:show("提升战斗人物"..lifeStr..attackStr)
						param.handler()
						layer:removeFromParent(true)
					else
						Toast:show("龙珠不足")
					end
				end
			elseif type == ccui.TouchEventType.began then
				if i == 2 then
					btnDown()
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	return layer
end

function PubDialog:newLeaveEndlessDialog(param)
	local dataUser = require("tables.dataUser")

	local layer = cc.Layer:create()
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.PUB_DIALOG_RELIVE)
	layer:addChild(ui)

	--1关闭  2确定
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_16_0"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
	}
	--1发光  2正常  3press
	local img = {
		[1] = btn[2]:getChildByName("Image_27"),
		[2] = btn[2]:getChildByName("Image_87"),
		[3] = btn[2]:getChildByName("Image_87_0"),
		[4] = ui:getChildByName("Image_18"):getChildByName("Image_13"),
		[5] = ui:getChildByName("Image_18"):getChildByName("Image_22"),
	}
	--1.退出战斗  不保存进度  2是否确定退出
	local lbl = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Label_22"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Label_23"),
	}

	local dispatcher = layer:getEventDispatcher()

	local function btnUp()
		img[1]:setVisible(true)
		img[2]:setVisible(true)
		img[3]:setVisible(false)
	end
	btnUp()
	local function btnDown()
		img[1]:setVisible(false)
		img[2]:setVisible(false)
		img[3]:setVisible(true)
	end

	img[4]:setVisible(false)
	img[5]:setVisible(false)

	for i = 1,2 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					layer:removeFromParent(true)
				elseif i == 2 then
					param.handler()
				end
			elseif type == ccui.TouchEventType.began then
				if i == 2 then
					btnDown()
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end

	return layer
end

return PubDialog