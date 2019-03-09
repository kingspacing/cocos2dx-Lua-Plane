local WelcomeLayer = class("WelcomeLayer",function()
	return cc.Layer:create()
end)

require "display"
require "ui"

function WelcomeLayer:ctor()
	local dataUser = require("tables.dataUser")
	
	local bg = cc.Sprite:create(GAME_IMAGE.WELCOME_SCENE_BG,cc.rect(0,0,640,1140))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)
	
	local start = cc.Sprite:create("ui/welcomeScene/welcome_start_btn.png")
	start:setPosition(display.cx,100)
	self:addChild(start)
	start:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.ScaleTo:create(0.5,0.9),
		cc.ScaleTo:create(0.5,1.1)
	)))
	start:setVisible(false)
	
	local loadTip = ccui.Text:create("游戏加载中，请耐心等待","arial",28)
	loadTip:setPosition(display.cx,100)
	self:addChild(loadTip)
	loadTip:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.ScaleTo:create(0.5,0.9),
		cc.ScaleTo:create(0.5,1.1)
	)))
	
	--礼包逻辑
	local gift = dataUser.getGift()
	gift.onceIn = true
	dataUser.flushJson()

	local resFiles = {
		GAME_ANIM.INDEX_SCENE_ANI_FILE,              -- 强化进阶
		GAME_ANIM.INDEX_SCENE_ANI_BAOQI_FILE,        -- 爆气
		GAME_IMAGE.INDEX_SCENE_UI_FILE,              -- 主界面UI
		GAME_IMAGE.LEVEL_SCENE_UI_FILE,
		[5] = "ui/levelScene/item_animat.plist",
		[6] = "ui/commonUI/common.plist",
		[7] = "ui/guide/guideRes.plist"            --guide
	}
	local resImages = {
		GAME_ANIM.INDEX_SCENE_ANI_IMG,
		GAME_ANIM.INDEX_SCENE_ANI_BAOQI_IMG,
		GAME_IMAGE.INDEX_SCENE_UI_IMG,
		GAME_IMAGE.LEVEL_SCENE_UI_IMG,
		[5] = "ui/levelScene/item_animat.pvr.ccz",
		[6] = "ui/commonUI/common.pvr.ccz",
		[7] = "ui/guide/guideRes.png"            --guide
	}
	
	for i = 0,3 do
		resFiles[i+8] = "ui/index_ui"..i..".plist"
		resImages[i+8] = "ui/index_ui"..i..".png"
	end 
	
	local isLoading = false
	local currentRes = 0
	
	
	local function loaded(texture)
		cc.SpriteFrameCache:getInstance():addSpriteFrames(resFiles[currentRes])        
		isLoading = false
	end

	local function load(configFilePath)
		isLoading = true
		cc.Director:getInstance():getTextureCache():addImageAsync(configFilePath,loaded)
	end
	
	local function onTouchBegan(touch, event)
		--友盟统计第一步
		MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_STEP, 1))
	--    print("友盟统计第1步")
		MyApp:enterIndexScene()
		return true
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	listener:setEnabled(false)

	--可以在此加载游戏资源   
	local function update()
		if isLoading then
			return
		end
		currentRes = currentRes + 1
		if currentRes > #resImages then
			self:unscheduleUpdate()
			start:setVisible(true)
			listener:setEnabled(true)
			loadTip:setVisible(false)
			require "config"
			require "ui"
			require "chart"
			return
		end
		load(resImages[currentRes])
	end
	
	local function loadGameRes()
		self:scheduleUpdateWithPriorityLua(update,0)
	end

-------------------------------------热更新

	--获取本地版本号
	local pathToSave = cc.FileUtils:getInstance():getWritablePath()
	local assetsManager = cc.AssetsManager:new("http://update.starwars.910app.com/dragonball/package.zip",
		"http://update.starwars.910app.com/dragonball/versioncode.txt",
		pathToSave)
	assetsManager:retain()
	local version = assetsManager:getVersion()
	if version == "" then 
		version = MyApp:getVersion()
	else
		version = tonumber(version)
		if MyApp:getVersion() > version  then 
			version = MyApp:getVersion()
		end
	end

	--正在更新
	local function startUpdate()
		local bgLayer = cc.LayerColor:create(cc.c4f(0,0,0,160))
		self:addChild(bgLayer, 10)
		local w = 600
		local h = 100
		local bg = ccui.Scale9Sprite:createWithSpriteFrameName("update_bg.png")
		bg:setPosition(display.cx, display.cy)
		bg:setPreferredSize(cc.size(w, h))
		bgLayer:addChild(bg, 1)
		local progressBg = ccui.Scale9Sprite:createWithSpriteFrameName("update_progress_bg.png")
		progressBg:setPreferredSize(cc.size(560, 30))
		progressBg:setPosition(w/2,h/2 + 10)
		bg:addChild(progressBg,2)

		local progress = cc.ProgressTimer:create(display.newSprite("#update_progress.png"))
		progress:setPosition(w/2,h/2 + 10)
		progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)

		progress:setMidpoint(cc.p(0, 0))
		progress:setBarChangeRate(cc.p(1, 0))
		progress:setPercentage(0)
		bg:addChild(progress, 3)

		local pText = ccui.Text:create()
		pText:setString("0%")
		pText:setFontSize(25)
		pText:setPosition(w/2,h/2 + 10)
		bg:addChild(pText, 4)

		local text = ccui.Text:create()
		text:setString("正在更新资源，请耐心等待......")
		text:setFontSize(25)
		text:setAnchorPoint(0.5, 0.5)
		text:setPosition(w/2, h/2 - 30)
		bg:addChild(text, 1)

		local function onError(errorCode)
			if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then

			elseif errorCode == cc.ASSETSMANAGER_NETWORK then

			end

			performWithDelay(self, function()
				bgLayer:removeFromParent()
				loadGameRes()
			end, 0.5)
		end
		local function onProgress( percent )
			progress:setPercentage(tonumber(percent))
			pText:setString(percent .. "%")
		end

		local function onSuccess()
			package.loaded["app.MyApp"] = nil
			package.loaded["config"] = nil
			require "app.MyApp"
			require "config"
			performWithDelay(self, function()
				bgLayer:removeFromParent()
				local paths = cc.FileUtils:getInstance():getSearchPaths()
				table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath() .. "src")
				table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath() .. "res")
				table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath())
				cc.FileUtils:getInstance():setSearchPaths(paths)
				loadGameRes()
			end, 0.5)
		end
		assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
		assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
		assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
		assetsManager:setConnectionTimeout(3)
		assetsManager:update()
	end

	--更新弹窗
	local function showUpdateDialog(content)
		local w = 600
		local h = 400
		display.addSpriteFramesWithFile(GAME_IMAGE.UPDATE_FILE, GAME_IMAGE.UPDATE_IMAGE)
		local bgLayer = cc.LayerColor:create(cc.c4f(0,0,0,160))
		self:addChild(bgLayer, 10)
		local bg = ccui.Scale9Sprite:createWithSpriteFrameName("update_dialog.png")
		bg:setPosition(display.cx, display.cy)
		bg:setInsetLeft(100)
		bg:setInsetRight(100)
		bg:setInsetTop(80)
		bg:setInsetBottom(80)
		bg:setPreferredSize(cc.size(w, h))
		bgLayer:addChild(bg, 1)

		local text = ccui.Text:create()
		text:setString("需要更新" .. content .. "的资源文件\n        是否立即更新！")
		text:setFontSize(30)
		text:setAnchorPoint(0.5, 0.5)
		text:setPosition(w/2, h/2 + 30)
		bg:addChild(text, 1)

		local items = {}
		local texts = {"暂不更新", "立即更新"}
		for i = 1, 2 do 
			items[i] = ui.newImageMenuItem({
				image = "#update_b" .. i .. ".png"
				, imageSelected = "#update_b" .. i .. "_pressed.png"
				, x = w/2 - 100 + (i-1)*200
				, y = h/2 - 100
				, listener = function ()
					if i == 1 then 
						bgLayer:removeFromParent()
						performWithDelay(self, function()
							loadGameRes()
						--    print "hehe"
						end, 0.5)
					elseif i == 2 then 
						bgLayer:removeFromParent()
						startUpdate()
					end
				end
			})
			local text = ccui.Text:create()
			text:setString(texts[i])
			text:setFontSize(30)
			text:setPosition(items[i]:getContentSize().width/2, items[i]:getContentSize().height/2)
			items[i]:addChild(text, 1)
		end
		bg:addChild(ui.newMenu(items), 1)
	end 

	--连接了网络
	if MyApp:isConnect() then 
		print("Network Connected!")
		local vHttp = cc.XMLHttpRequest:new()
		vHttp.timeout = 300
		vHttp.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
		vHttp:open("GET", "http://update.starwars.910app.com/dragonball/versioncode.txt")
		local function onReadyStateChange()
			if vHttp.status == 200 then
				local v = tonumber(vHttp.response)
				print("New Version:" .. v)
				print("Old Version:" .. version)
				if v > version then
					local sHttp = cc.XMLHttpRequest:new()
					sHttp.timeout = 300
					sHttp.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
					sHttp:open("GET", "http://update.starwars.910app.com/dragonball/size.txt")
					sHttp:registerScriptHandler(function()
						self:unscheduleUpdate()
						if sHttp.status == 200 then
					 --       print("size:" .. sHttp.response)
							showUpdateDialog(sHttp.response)
						else
							performWithDelay(self, function()
								loadGameRes()
							end, 0.5)
						end
					end)
					sHttp:send()
				else 
					performWithDelay(self, function()
						loadGameRes()
					end, 0.5)
				end
			else 
				performWithDelay(self, function()
					loadGameRes()
				end, 0.5)
			end
		end
		vHttp:registerScriptHandler(onReadyStateChange)
		vHttp:send()
	else 
		performWithDelay(self, function()
			loadGameRes()
		end, 0.5)
	end

	--3秒时间网络超时
	local t = 0
	self:scheduleUpdateWithPriorityLua(function()
		if t>= 3*60 then 
			self:unscheduleUpdate()
			loadGameRes()
		else
			t=t+1
		end
	end,0)
end

return WelcomeLayer