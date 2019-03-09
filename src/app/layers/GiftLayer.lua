local GiftLayer = class("GiftLayer",function()
	return cc.Layer:create()
end)

function GiftLayer:ctor(param)
	local dataUser = require("tables.dataUser")
	local Toast = require("app.layers.Toast")
	
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.GIFT_LAYER_UI)
	self:addChild(ui)
	
	--1关闭  2购买
	local btn = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Button_18"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Button_29"),
	}
	--1金币  2护盾  3核弹
	local lbl = {
		[1] = ui:getChildByName("Image_18"):getChildByName("Image_22"):getChildByName("Label_23"),
		[2] = ui:getChildByName("Image_18"):getChildByName("Image_22_0"):getChildByName("Label_23"),
		[3] = ui:getChildByName("Image_18"):getChildByName("Image_22_1"):getChildByName("Label_23"),
	}
	local img = {
		[1] = btn[2]:getChildByName("Image_30"),
		[2] = btn[2]:getChildByName("Image_31_0"),
		[3] = btn[2]:getChildByName("Image_31"),
	}
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
	
	--反光
	local panel = ui:getChildByName("Image_18")
	local light = cc.Sprite:createWithSpriteFrameName("lbPic3.png")
	light:setPosition(160,458)
	light:setOpacity(0)
	light:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.CallFunc:create(
			function()
				light:setPositionX(160) light:setOpacity(0) 
			end),
		cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveBy:create(0.2,cc.p(30,0))),
		cc.MoveBy:create(0.3,cc.p(50,0)),
		cc.Spawn:create(cc.FadeOut:create(0.2),cc.MoveBy:create(0.2,cc.p(30,0))),
		cc.DelayTime:create(2)
	)))
	panel:addChild(light)
	
	--单个星星
	local function newStar(x,y)
		local sp = cc.Sprite:createWithSpriteFrameName("sljmPic12.png")  
		sp:setPosition(x,y)
		sp:setScale(0)
		sp:runAction(cc.Sequence:create(
			cc.Spawn:create(
	  --          cc.RotateBy:create(1,180),
				cc.Sequence:create(
					cc.ScaleTo:create(0.5,1),
					cc.ScaleTo:create(0.5,0)
				)),
			cc.RemoveSelf:create()
		))
		panel:addChild(sp)
	end
	--星星
	local time = 0
	local function update()
		if time == 120 then
			time = 0
		end
		if time%20 == 0 then
			local randX = 220
			local randY = 460
			newStar(math.random(randX - 100,randX + 100),math.random(randY - 40,randY + 40))
		end
		time = time + 1
	end
	self:scheduleUpdateWithPriorityLua(update,0) 
	
	btn[1]:setScale(0.7)
	local dispatcher = self:getEventDispatcher()
	local data = {200000,10,10}
	
	for i = 1,3 do
		lbl[i]:setString("x"..data[i])
	end
	
	for i = 1,2 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					if param ~= nil and param.handler ~= nil then
						param.handler()
					end
				
					self:removeFromParent(true)
				elseif i == 2 then
					MyApp:pay("pay1")
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
		if event._usedata == "pay1" then
			Toast:show(LANGUAGE_CHINESE.GiftLayer[1])
			dataUser.increaseGold(data[1])
			dataUser.increaseShield(data[2])
			dataUser.increaseBoom(data[3])

			local gift = dataUser.getGift()
			gift.buyTime = gift.buyTime + 1
			dataUser.flushJson()
			local TopLayer = cc.Director:getInstance():getRunningScene():getChildByName("TopLayer")
			if TopLayer ~= nil then
				TopLayer:fresh()
			end
			btnUp()
			
			if param ~= nil and param.handler ~= nil then
				param.handler()
			end
			
			self:removeFromParent(true)
		end
	end
	--监听付费点成功付费反馈
	local listener = cc.EventListenerCustom:create("pay_result", paySuccessCallback)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return GiftLayer