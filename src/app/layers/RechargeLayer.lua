local RechargeLayer = class("RechargeLayer",function()
	return cc.Layer:create()
end)

function RechargeLayer:ctor()
	local dataUser = require("tables.dataUser")
	local dataUi = require("tables.dataUi")
	local Toast = require("app.layers.Toast")
	
	local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.RECHARGE_LAYER_UI)
	self:addChild(ui)
	
	--1返回  2-6购买（左上到右下）
	local btn = {
		[1] = ui:getChildByName("Button_61"),
		[2] = ui:getChildByName("Image_27"):getChildByName("Image_21_0"):getChildByName("Button_34"),
		[3] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0"):getChildByName("Button_34"),
		[4] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1"):getChildByName("Button_34"),
		[5] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1_2"):getChildByName("Button_34"),
		[6] = ui:getChildByName("Image_27"):getChildByName("Image_20"):getChildByName("Button_75"),
	}
	
	--1.1人民币  1.2金币  1.3赠送
	local lbl = {
		[1] = {
			[1] = ui:getChildByName("Image_27"):getChildByName("Image_21_0"):getChildByName("Label_28"),
			[2] = ui:getChildByName("Image_27"):getChildByName("Image_21_0"):getChildByName("Label_30"),
			[3] = ui:getChildByName("Image_27"):getChildByName("Image_21_0"):getChildByName("Label_30_0"),
		},
		[2] = {
			[1] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0"):getChildByName("Label_28"),
			[2] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0"):getChildByName("Label_30"),
			[3] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0"):getChildByName("Label_30_0"),
		},
		[3] = {
			[1] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1"):getChildByName("Label_28"),
			[2] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1"):getChildByName("Label_30"),
			[3] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1"):getChildByName("Label_30_0"),
		},
		[4] = {
			[1] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1_2"):getChildByName("Label_28"),
			[2] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1_2"):getChildByName("Label_30"),
			[3] = ui:getChildByName("Image_27"):getChildByName("Image_21_0_0_1_2"):getChildByName("Label_30_0"),
		},
	}
	
	local img = {
		--反光  文字  文字Press
		[5] = {
			[1] = btn[6]:getChildByName("Image_76"),
			[2] = btn[6]:getChildByName("Image_77_0"),
			[3] = btn[6]:getChildByName("Image_77"),
		},
	}
	for i = 1,4 do
		img[i] = {}
		img[i][1] = btn[i+1]:getChildByName("Image_37")
		img[i][2] = btn[i+1]:getChildByName("Image_36_0")
		img[i][3] = btn[i+1]:getChildByName("Image_36")
	end
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
	for i = 1,5 do
		btnUp(i)
	end
	
	--30元充值不可更改，数字为图片文件
	for i = 1,4 do
		local t = dataUi.getRecharge(i)
		lbl[i][1]:setString(t.money..LANGUAGE_CHINESE.RechargeLayer[1])
		lbl[i][2]:setString(t.gold..LANGUAGE_CHINESE.RechargeLayer[2])
		lbl[i][3]:setString(t.giftGold)
	end

	local dispatcher = self:getEventDispatcher()
	for i = 1,6 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					MyApp:enterIndexScene()
				elseif i >= 2 and i <= 6 then
					MyApp:pay("pay"..i+5)
--                    Toast:show(LANGUAGE_CHINESE.RechargeLayer[3])
--                    local t = dataUi.getRecharge(i-1)
--                    dataUser.increaseGold(t.gold + t.giftGold)
--                    dataUser.flushJson()
--                    self:getParent():getChildByName("TopLayer"):fresh()
--                    btnUp(i - 1)
				end
			elseif type == ccui.TouchEventType.began then
				if i >= 2 and i <= 6 then
					btnDown(i - 1)
				end
			elseif type == ccui.TouchEventType.canceled then
				if i >= 2 and i <= 6 then
					btnUp(i - 1)
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
	
	local function payFunc(n)
		Toast:show(LANGUAGE_CHINESE.RechargeLayer[3])
		local t = dataUi.getRecharge(n)
		dataUser.increaseGold(t.gold + t.giftGold)
		dataUser.flushJson()
		self:getParent():getChildByName("TopLayer"):fresh()
		btnUp(n)
	end
	
	local function paySuccessCallback(event)
		if event._usedata == "pay7" then
			payFunc(1)
		elseif event._usedata == "pay8" then
			payFunc(2)
		elseif event._usedata == "pay9" then
			payFunc(3)
		elseif event._usedata == "pay10" then
			payFunc(4)
		elseif event._usedata == "pay11" then
			payFunc(5)
		end
	end
	--监听付费点成功付费反馈
	local listener = cc.EventListenerCustom:create("pay_result", paySuccessCallback)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return RechargeLayer