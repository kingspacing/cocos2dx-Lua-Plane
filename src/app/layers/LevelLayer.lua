local LevelLayer = class("LevelLayer",function()
	return cc.Layer:create()
end)

function LevelLayer:ctor(param)
	local dataUser = require("tables.dataUser")
	local dataLevel = require("tables.dataLevel")
	local LevelInfoLayer = require("app.layers.LevelInfoLayer")
	local dataUi = require("tables.dataUi")
	local GuideLayer = require("app.layers.GuideLayer")
	local Toast = require("app.layers.Toast")
	local EndlessShopLayer = require("app.layers.EndlessShopLayer")
	IS_GUIDING = false
	--是否测试关卡
	local isTest = false

	--背景层
	local function newBgLayer()
		local layer = cc.Layer:create()
		
		for i = 1,3 do
			local bg1 = cc.Sprite:create(GAME_IMAGE["LEVEL_SCENE_UI_CUT_BG_"..i],cc.rect(0,0,640,1122))
			bg1:setPosition(0,(i-1) * 1122)
			bg1:setAnchorPoint(0,0)
			layer:addChild(bg1)
		end
		
		--小方格
		local xNum = math.ceil(display.width / 33)
		local yNum = math.ceil(display.height / 33)
		for i = 1,xNum do
			for j = 1,yNum do
				local sp = cc.Sprite:createWithSpriteFrameName("mxjmPic17.png")
				sp:setAnchorPoint(0,0)
				sp:setPosition((i-1)* 31,(j-1) * 31)
				self:addChild(sp)
			end
		end
		--绿外框
		local bg2 = ccui.Scale9Sprite:createWithSpriteFrameName("mxjmPic15.png",cc.rect(10,10,232,152))
		bg2:setContentSize(640,1140)
		bg2:setPosition(0,0)
		bg2:setAnchorPoint(0,0)
		self:addChild(bg2,0)
		
		return layer
	end
	--中景运动层
	local function newActionLayer()
		local layer = cc.Layer:create()
		
		--云
		local cloud = {}
		for i = 1,6 do
			cloud[i] = cc.Sprite:createWithSpriteFrameName("LevelScene_cloud"..math.random(2,3)..".png")
			cloud[i]:setScale(2)
			layer:addChild(cloud[i],3)
		end
		
		cloud[1]:setPosition(-1000,750)
		cloud[2]:setPosition(1000,1500)
		cloud[3]:setPosition(-1000,2250)
		cloud[4]:setPosition(1000,3000)
		cloud[5]:setPosition(-1000,3750)
		cloud[6]:setPosition(1000,4500)
		
		for i = 1,6 do
			if i == 2 or i == 4 or i == 6 then
				cloud[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.MoveBy:create(16,cc.p(-math.random(1900,2000),0)),
					cc.MoveBy:create(16,cc.p(math.random(1900,2000),0))
				)))
			else
				cloud[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.MoveBy:create(16,cc.p(math.random(1900,2000),0)),
					cc.MoveBy:create(16,cc.p(-math.random(1900,2000),0))
				)))
			end
		end
		
		--陨石
		local stone = {}
		for i = 1,3 do
			stone[i] = cc.Sprite:createWithSpriteFrameName("LevelScene_stone"..i..".png")
			layer:addChild(stone[i],2)
		end
		
		stone[3]:setPosition(500,4800)
		stone[2]:setPosition(150,5000)
		stone[1]:setPosition(180,5200)
		
		--星球
		local ball = {}
		ball[1] = cc.Sprite:createWithSpriteFrameName("LevelScene_bigBall.png")
		ball[2] = cc.Sprite:createWithSpriteFrameName("LevelScene_smallBall.png")
		layer:addChild(ball[1],1)
		layer:addChild(ball[2],1)
		
		for i = 1,2 do
			ball[i]:runAction(cc.RepeatForever:create(cc.RotateBy:create(60,360)))
		end
		
		ball[2]:setPosition(200,4800)
		ball[1]:setPosition(500,5300)
		
		return layer
	end
	--关卡按钮层
	local function newBtnLayer(isOverLimmit)
		self.isOverLimmit = isOverLimmit
		local layer = cc.Layer:create()
		
		local btn = {}
		--总关卡数
		local totalLevel
		local cache = cc.SpriteFrameCache:getInstance()
		
		if isOverLimmit == false then
			totalLevel = 49
		else
			totalLevel = 15
		end
		self.totalLevel = totalLevel
		
		local color = {}
		color.blue = cc.c3b(0,236,247)
		color.red = cc.c3b(254,126,130)
		
		local positionBtn = {
			[1] = {x = 506,y = 202},
			[2] = {x =198,y = 417},
			[3] = {x =462,y = 618},
			[4] = {x =141,y = 814},
			[5] = {x =515,y = 1022},
			[6] = {x =129,y = 1231},
			[7] = {x =533,y = 1427},
			[8] = {x =107,y = 1644},
			[9] = {x =529,y = 1835},
			[10] = {x =128,y = 2023},
			[11] = {x =524,y = 2249},
			[12] = {x =103,y = 2415},
			[13] = {x =473,y = 2631},
			[14] = {x =198,y = 2805},
			[15] = {x =459,y = 3051},
			[16] = {x =155,y = 3243},
			[17] = {x =444,y = 3432},
			[18] = {x =111,y = 3634},
			[19] = {x =486,y = 3842},
			[20] = {x =126,y = 4045},
			[21] = {x =485,y = 4237},
			[22] = {x =135,y = 4420},
			[23] = {x =521,y = 4640},
			[24] = {x =112,y = 4807},
			[25] = {x =515,y = 5046},
			[26] = {x =107,y = 5220},
			[27] = {x =458,y = 5413},
			[28] = {x =170,y = 5647},
			[29] = {x =466,y = 5816},
			[30] = {x =165,y = 6037},
			[31] = {x =494,y = 6202},
			[32] = {x =174,y = 6410},
			[33] = {x =453,y = 6649},
			[34] = {x =183,y = 6827},
			[35] = {x =527,y = 7004},
			[36] = {x =190,y = 7221},
			[37] = {x =480,y = 7447},
			[38] = {x =163,y = 7611},
			[39] = {x =495,y = 7846},
			[40] = {x =187,y = 8037},
			[41] = {x =497,y = 8203},
			[42] = {x =164,y = 8412},
			[43] = {x =484,y = 8628},
			[44] = {x =115,y = 8831},
			[45] = {x =514,y = 9033},
			[46] = {x =185,y = 9240},
			[47] = {x =485,y = 9401},
			[48] = {x =143,y = 9638},
			[49] = {x =300,y = 9805},}
		self.positionBtn = positionBtn
		
		local level
		if isOverLimmit == false then
			level = dataUser.getLevel()
		else
			level = dataUser.getLimitLevel()
		end
		local function newBtn(id,isFirstPass)
			local data
			if isOverLimmit == false then
				data = dataLevel.getLevelInfo(id)
			else
				data = dataLevel.getLevelInfo(100 + id)
			end
			
			--select效果
			local function newAnimateSelectItem(callback)
				local sp = cc.Sprite:create()
				local tb = {}
				for i = 1,15 do
					table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("item_select"..i..".png"))
				end
				local animation = cc.Animation:createWithSpriteFrames(tb,0.05)
				sp:runAction(
					cc.RepeatForever:create(cc.Animate:create(animation))
				)
				return sp
			end
			--open效果
			local function newAnimateOpenItem(callback)
				local sp = cc.Sprite:create()
				local tb = {}
				for i = 1,6 do
					table.insert(tb,cc.SpriteFrameCache:getInstance():getSpriteFrame("item_start"..i..".png"))
				end
				local animation = cc.Animation:createWithSpriteFrames(tb,0.05)
				sp:runAction(cc.Sequence:create(
					cc.Repeat:create(cc.Animate:create(animation),1),
					cc.CallFunc:create(function()
					if callback ~= nil then
						callback()
					end
					sp:removeFromParent(true) 
					end)
				))
				return sp
			end
			--当前关卡提示
			local function newAnimateTip()
				local sp = cc.Sprite:createWithSpriteFrameName("dangqiantishi.png")
				sp:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.MoveBy:create(0.5,cc.p(0,20)),
					cc.MoveBy:create(0.5,cc.p(0,-20))
					)  
				))
				return sp
			end
			
			--BOSS
			if data.bossInfo ~= nil then
				--开启
				if id < #level or isTest then
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic10.png")
					local head = cc.Sprite:createWithSpriteFrameName("mxjmPic7.png")
					head:setPosition(btn[id]:getContentSize().width/2,btn[id]:getContentSize().height)
					btn[id]:addChild(head)
				--当前关卡
				elseif id == #level then
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic11.png")
					local function callback()
						local sp = newAnimateSelectItem()
						sp:setPosition(60,65)
						sp:setColor(color.red)
						btn[id]:setSpriteFrame(cache:getSpriteFrame("mxjmPic10.png"))
						btn[id]:addChild(sp,-1)

						local tip = newAnimateTip()
						tip:setPosition(57,70)
						btn[id]:addChild(tip)
						
						self.canBtnClick = true
					end
					local function deleyRun()
						local sp = newAnimateOpenItem(callback)
						sp:setPosition(48,110)
						sp:setColor(color.blue)
						btn[id]:addChild(sp,-1)
					end
					--首次通关
					if isFirstPass == true then
						self.canBtnClick = false
						performWithDelay(layer,deleyRun,2)
					else
						callback()
					end  
				--未开启
				else
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic11.png")
				end
			--普通
			else
				--开启
				if id < #level or isTest then
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic12.png")
					--关卡数字为散图，做处理
					local numLen = tostring(id):len()
					local function newNumber(id,num,x,y)
						local number = cc.Sprite:createWithSpriteFrameName("shuzilan"..num..".png")
						number:setPosition(x,y)
						btn[id]:addChild(number)
					end
					if numLen == 1 then
						newNumber(id,id,btn[id]:getContentSize().width/2,btn[id]:getContentSize().height/2 + 20)
					elseif numLen == 2 then
						newNumber(id,tostring(id):sub(1,1),btn[id]:getContentSize().width/2 - 15,btn[id]:getContentSize().height/2 + 20)
						newNumber(id,tostring(id):sub(2,2),btn[id]:getContentSize().width/2 + 15,btn[id]:getContentSize().height/2 + 20)                   
					end
				--当前关卡
				elseif id == #level then
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic13.png")
					local function callback()
						local sp = newAnimateSelectItem()
						sp:setPosition(50,60)
						sp:setColor(color.blue)
						btn[id]:setSpriteFrame(cache:getSpriteFrame("mxjmPic12.png"))
						btn[id]:addChild(sp,-1)
						
						local tip = newAnimateTip()
						tip:setPosition(55,63)
						btn[id]:addChild(tip)
						
						self.canBtnClick = true
					end
					local function deleyRun()
						local sp = newAnimateOpenItem(callback)
						sp:setPosition(40,100)
						sp:setColor(color.blue)
						btn[id]:addChild(sp,-1)
					end
					--首次通关
					if isFirstPass == true then
						self.canBtnClick = false
						performWithDelay(layer,deleyRun,2)
					else
						callback()
					end
				--未开启
				else
					btn[id] = cc.Sprite:createWithSpriteFrameName("mxjmPic13.png")
				end     
			end   
			
			--按钮ID 生成每个按钮的星星
			local function newStar(btnId)
				--对应关卡的星星数
				local num
				if isOverLimmit == false then
					num = dataUser.getLevel()[btnId].star
				else
					num = dataUser.getLimitLevel()[btnId].star
				end
				
				if num <= 0 then
					return
				end
				
				local starBg = cc.Sprite:createWithSpriteFrameName("mxjmPic9.png")
				starBg:setPosition(btn[btnId]:getContentSize().width/2,-10)
				btn[btnId]:addChild(starBg)

				local node = cc.Node:create()
				for i = 1,num do
					local star = cc.Sprite:createWithSpriteFrameName("zjmStar.png")
					star:setPosition((i-1)*30,0)
					node:addChild(star)
				end
				node:setPosition(starBg:getContentSize().width/2 - (num - 1)/2*30,starBg:getContentSize().height/2)
				starBg:addChild(node)
			end
			
			if id <= #level then
				newStar(id)
			end
			
			btn[id]:setPosition(positionBtn[id].x,positionBtn[id].y)
			layer:addChild(btn[id])
			
			--按钮触摸
			local isTouch = false
			local tPoint
			local function onBtnStart(touch,event)
				local width = btn[id]:getContentSize().width
				local height = btn[id]:getContentSize().height
				local target = event:getCurrentTarget()
				local locationInNode = target:convertToNodeSpace(touch:getLocation())
				local s = target:getContentSize()
				local rect = cc.rect(0,0,width,height)
				if cc.rectContainsPoint(rect, locationInNode) then
					isTouch = true
					tPoint = touch:getLocation()
					return true
				end
				return false
			end
			local function onBtnMove(touch,event)
				local point = touch:getLocation()
				if cc.pGetDistance(point, tPoint) > 10 then 
					isTouch = false
				end
			end
			local function onBtnEnd(touch,event)                      
				if isTouch then
					AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
					
					--跑完动画才能继续打下一关卡
					if self.canBtnClick == false then
						return
					end
					
					if IS_GUIDING then
						self:getParent():removeChildByTag(GuideLayer.TAG)
					end
					
					if data.bossInfo == nil then
						self:getParent():addChild(LevelInfoLayer:newNormalLayer(id,isOverLimmit,param.heroId,self.battle),10)
					else
						self:getParent():addChild(LevelInfoLayer:newBossLayer(id,isOverLimmit,param.heroId,self.battle),10)
					end
					isTouch = false
				end
			end
			
			if id <= #level or isTest then
				local listener = cc.EventListenerTouchOneByOne:create()
				listener:setSwallowTouches(false)
				listener:registerScriptHandler(onBtnStart,cc.Handler.EVENT_TOUCH_BEGAN)
				listener:registerScriptHandler(onBtnMove,cc.Handler.EVENT_TOUCH_MOVED)
				listener:registerScriptHandler(onBtnEnd,cc.Handler.EVENT_TOUCH_ENDED)
				local eventDispatcher = layer:getEventDispatcher()
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener, btn[id])
			end
		end
		
		--根据两点生成路线
		local function newLoad(id,p1,p2,isFirstPass)
			local point = cc.p(p2.x - p1.x,p2.y - p1.y)
			local s = cc.pGetLength(point) - 40
			local angle = - cc.pGetAngle(point,cc.p(1,0))
			--路线图片间距
			local distance = 50
			local num = math.floor(s/distance)
			if num ~= 0 then
				--首次开启关卡
				if id == #level - 1 and isFirstPass == true then
					local levelBtn = {}
					for i = 1,num do
						if id <= #level - 1 then
							levelBtn[i] = cc.Sprite:createWithSpriteFrameName("mxjmPic5.png")
						end
						levelBtn[i]:setPosition(p1.x + i*distance*math.cos(angle),p1.y + i*distance*math.sin(angle))
						layer:addChild(levelBtn[i],-1)
					end
					
					local node = cc.Node:create()
					local i = 1
					local time = 0
					local function updateLoad()
						if time % 20 == 0 then
							levelBtn[i]:setSpriteFrame(cache:getSpriteFrame("mxjmPic4.png"))
							i = i + 1
						end
						if i == num + 1 then
							node:removeFromParent(true)
						end
						time = time + 1
					end
					node:scheduleUpdateWithPriorityLua(updateLoad,0)
					layer:addChild(node)
				else
					for i = 1,num do
						local sp
						if id <= #level - 1 then
							sp = cc.Sprite:createWithSpriteFrameName("mxjmPic4.png")
						else
							sp = cc.Sprite:createWithSpriteFrameName("mxjmPic5.png")
						end
						sp:setPosition(p1.x + i*distance*math.cos(angle),p1.y + i*distance*math.sin(angle))
						layer:addChild(sp,-1)
					end
				end
				
			end
		end
		local isFirstPass = dataUser.getFirstPass()
		for i = 1,totalLevel do
			newBtn(i,isFirstPass)
		end
		for i = 1,totalLevel - 1 do
			newLoad(i,positionBtn[i],positionBtn[i + 1],isFirstPass)
		end
		if isFirstPass == true then
			dataUser.changeFirstPass(false)
		end
		
		--初始化视角位置
		local playLevel = dataUser.getPlayLevel()
		local currentLevel
		if self.isOverLimmit == true then
			currentLevel = playLevel[3]
		else
			currentLevel = playLevel[2]
		end
		if btn[currentLevel]:getPositionY() >= 480 and currentLevel < totalLevel then
			self.viewPositionY = btn[currentLevel + 1]:getPositionY()
		elseif currentLevel >= totalLevel then
			self.viewPositionY = btn[totalLevel]:getPositionY() - 200
		else
			self.viewPositionY = 480
		end
		dataUser.flushJson()
		
		return layer
	end

	--菜单层
	--返回按钮
	local backBTN
	local function newMenuLayer()
		local layer = cc.Layer:create()
		local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.LEVEL_LAYER_UI)
		layer:addChild(ui)

		--1返回  2极限模式  3无尽模式
		local btn = {
			[1] = ui:getChildByName("Button_61"),
			[2] = ui:getChildByName("Button_84_0"),
			[3] = ui:getChildByName("Button_84"),
		}
		backBTN = btn[1]
		
		--1战斗力  2星星数
		local lbl = {
			[1] = ui:getChildByName("Image_71"):getChildByName("Label_46"),
			[2] = ui:getChildByName("Image_71"):getChildByName("Label_76"),
		}
		--1极限  2极限press 3普通  4普通press 5极限上  6极限下 7普通上  8普通下
		local img = {
			[1] = ui:getChildByName("Button_84_0"):getChildByName("Image_85"),
			[2] = ui:getChildByName("Button_84_0"):getChildByName("Image_85_0"),
			[3] = ui:getChildByName("Button_84_0"):getChildByName("Image_75"),
			[4] = ui:getChildByName("Button_84_0"):getChildByName("Image_75_0"),
			[5] = btn[2]:getChildByName("Image_85"),
			[6] = btn[2]:getChildByName("Image_85_0"),
			[7] = btn[2]:getChildByName("Image_75"),
			[8] = btn[2]:getChildByName("Image_75_0"),
			[9] = btn[3]:getChildByName("Image_85"),
			[10] = btn[3]:getChildByName("Image_85_0"),
		}
		--极限按钮表现
		local function btnUp()
			if self.isOverLimmit == false then
				img[5]:setVisible(true)
				img[6]:setVisible(false)
				img[7]:setVisible(false)
				img[8]:setVisible(false)
			else
				img[5]:setVisible(false)
				img[6]:setVisible(false)
				img[7]:setVisible(true)
				img[8]:setVisible(false)
			end
		end
		btnUp()
		local function btnDown()
			if self.isOverLimmit == false then
				img[5]:setVisible(false)
				img[6]:setVisible(true)
				img[7]:setVisible(false)
				img[8]:setVisible(false) 
			else
				img[5]:setVisible(false)
				img[6]:setVisible(false)
				img[7]:setVisible(false)
				img[8]:setVisible(true)
			end
		end
		
		local function endlessBtnUp()
			img[9]:setVisible(true)
			img[10]:setVisible(false)
		end
		endlessBtnUp()
		local function endlessBtnDown()
			img[9]:setVisible(false)
			img[10]:setVisible(true)
		end
		
		local greenLine = cc.Sprite:createWithSpriteFrameName("mxjmPic2.png")
		greenLine:setPosition(display.width/2,display.height)
		ui:addChild(greenLine,0)
		greenLine:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.MoveBy:create(2,cc.p(0,-display.height)),
			cc.DelayTime:create(5),
			cc.CallFunc:create(function() 
				greenLine:setPosition(display.width/2,display.height) 
			end)
		)))
		
		local heroData = dataUser.getHero()
		local name = {LANGUAGE_CHINESE.IndexLayer[1],LANGUAGE_CHINESE.IndexLayer[2],LANGUAGE_CHINESE.IndexLayer[3]}
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
		local data = findHeroConsolidateTable(heroData[param.heroId].level,name[param.heroId])
		local attack = data["attack"..heroData[param.heroId].star]
		local life = data["life"..heroData[param.heroId].star]
		local dataUser = require("tables.dataUser")
		attack = math.floor(attack * dataUser.getAttack())
		life = math.floor(life * dataUser.getLife())
		local battleNum = (attack + life / 5)*5
		lbl[1]:setString(string.format(LANGUAGE_CHINESE.LevelLayer[2],battleNum))
		self.battle = (attack + life / 5)*5
		
		--展示星星数
		local function showStar()
			local level
			if self.isOverLimmit == false then
				level = dataUser.getLevel()
			else
				level = dataUser.getLimitLevel()
			end
			local starSum = 0
			for i,v in pairs(level) do
				starSum = starSum + v.star
			end
			lbl[2]:setString(starSum)
		end
		showStar()
		
		local mParticle
		local function newParticle()
			mParticle = {
				["left"] = cc.ParticleSystemQuad:create(GAME_PARTICLE.OVER_LIMIT_PARTICLE),
				["right"] = cc.ParticleSystemQuad:create(GAME_PARTICLE.OVER_LIMIT_PARTICLE),
				["bottom"] = cc.ParticleSystemQuad:create(GAME_PARTICLE.OVER_LIMIT_PARTICLE),
				["up"] = cc.ParticleSystemQuad:create(GAME_PARTICLE.OVER_LIMIT_PARTICLE),
			}
			mParticle["left"]:setPosition(cc.p(-20,display.cy))
			mParticle["left"]:setPosVar(cc.p(display.height / 2,0))
			layer:addChild(mParticle["left"])
			mParticle["left"]:setRotation(90)

			mParticle["right"]:setPosition(cc.p(display.width + 20,display.cy))
			mParticle["right"]:setPosVar(cc.p(display.height / 2,0))
			layer:addChild(mParticle["right"])
			mParticle["right"]:setRotation(-90)

			mParticle["bottom"]:setPosition(cc.p(display.cx,0))
			layer:addChild(mParticle["bottom"])

			mParticle["up"]:setPosition(cc.p(display.cx,display.height - 90))
			layer:addChild(mParticle["up"])
			mParticle["up"]:setRotation(180)
		end
		
		local function removeParticle()
			for i,v in pairs(mParticle) do
				v:removeFromParent(true)
			end
		end
		
		if self.isOverLimmit == true then
			newParticle()
		end
		
		local function showEndlessShop()
			cc.Director:getInstance():getRunningScene():addChild(EndlessShopLayer.new({
				heroId = param.heroId,
				toScene = "EndlessMainScene",
				isEndless = true,
			}))
		end
		
--        if param.isEndless then
--            showEndlessShop()
--        end
		
		for i = 1,3 do
			local function onBtn(sender,type)
				if type == ccui.TouchEventType.ended then
					AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
					if i == 1 then
						MyApp:enterIndexScene()
					elseif i == 2 then
						if self:getChildByName("btnLayerF") ~= nil then
							if battleNum < 15000 then
								Toast:show(LANGUAGE_CHINESE.LevelLayer[1])
								return
							end
							newParticle()
							self.layer3 = newBtnLayer(true)
							self.layer3:setName("btnLayerT")
							self:addChild(self.layer3,2)
							showStar()
							self.LimitN = 0.5
							self:getChildByName("btnLayerF"):removeFromParent(true)
						else
							removeParticle()
--                            newBtnParticle()
							self.layer3 = newBtnLayer(false)
							self.layer3:setName("btnLayerF")
							self:addChild(self.layer3,2)
							showStar()
							self.LimitN = 2
							self:getChildByName("btnLayerT"):removeFromParent(true)
						end
						btnUp()
						
						--视角位置切换
						local playLevel = dataUser.getPlayLevel()
						local currentLevel
						if self.isOverLimmit == true then
							currentLevel = playLevel[3]
							self.isOverLimmit = false
						else
							currentLevel = playLevel[2]
							self.isOverLimmit = true
						end
						if self.positionBtn[currentLevel].y >= 480 and currentLevel <= self.totalLevel then
							self.viewPositionY = self.positionBtn[currentLevel].y
						elseif currentLevel > self.totalLevel then
							self.viewPositionY = self.positionBtn[self.totalLevel].y
						else
							self.viewPositionY = 480
						end
						self.layer1:setPositionY( - (self.viewPositionY - 480) / 4)
						self.layer2:setPositionY( - (self.viewPositionY - 480) / 2)
						self.layer3:setPositionY( - (self.viewPositionY - 480))
					elseif i == 3 then
						endlessBtnUp()
						showEndlessShop()
					end
				elseif type == ccui.TouchEventType.began then
					if i == 2 then
						btnDown()
					elseif i == 3 then
						endlessBtnDown()
					end
				end
			end
			btn[i]:addTouchEventListener(onBtn)
		end
		
		return layer
	end
	
	--初始化场景
	self.layer1 = newBgLayer()
	self.layer2 = newActionLayer()
	
	local playLevel = dataUser.getPlayLevel()
	local currentLevel = playLevel[playLevel[1]]
	if playLevel[1] == 2 then
		self.layer3 = newBtnLayer(false)
		self.layer3:setName("btnLayerF")
		self.LimitN = 2
	elseif playLevel[1] == 3 then
		self.layer3 = newBtnLayer(true)
		self.layer3:setName("btnLayerT")
		self.LimitN = 0.5
	end
	
	self.layer4 = newMenuLayer()

	self:addChild(self.layer1,-1)
	self:addChild(self.layer2,1)
	self:addChild(self.layer3,2)
	self:addChild(self.layer4,3)

	--即时滑动速度
	local speed = 0
	--初始滑动速度
	local speedTemp = 0
	--背景图片大小
	local bgHeight = 1140
	local winHeight = cc.Director:getInstance():getWinSize().height

--    --开始时当前关卡的位置
--    self.viewPositionY = 0
	--计时器
	local time = 0
	--计时更新
	local schedule
	local eventDispatcher = self:getEventDispatcher()

	if self.viewPositionY < 480 then
		self.viewPositionY = 480
	elseif self.viewPositionY > 9600 then
		self.viewPositionY = 9600
	end
	self.layer1:setPositionY( - (self.viewPositionY - 480) / 4)
	self.layer2:setPositionY( - (self.viewPositionY - 480) / 2)
	self.layer3:setPositionY( - (self.viewPositionY - 480))
	
	--限制地图位置参数
	self.LimitN = 2
	--滑动处理
	local function scroll()
		if speedTemp > 0 then
			speed = speed - 0.2
		elseif speedTemp < 0 then
			speed = speed + 0.2
		end

		if speed * speedTemp > 0 then
			local temp1 = self.layer1:getPositionY() + speed / 4
			if temp1 > 0 then
				temp1 = 0
			elseif temp1 < - bgHeight * self.LimitN + winHeight - 960 then
				temp1 = - bgHeight * self.LimitN + winHeight - 960
			end
			self.layer1:setPositionY(temp1)
			local temp2 = self.layer2:getPositionY() + speed / 2
			if temp2 > 0 then
				temp2 = 0
			elseif temp2 < - bgHeight * self.LimitN / 2 * 4 + winHeight - 960 then
				temp2 = - bgHeight * self.LimitN / 2 * 4  + winHeight - 960
			end
			self.layer2:setPositionY(temp2)
			local temp3 = self.layer3:getPositionY() + speed
			if temp3 > 0 then
				temp3 = 0
			elseif temp3 < - bgHeight * self.LimitN * 4 + winHeight - 960 then
				temp3 = - bgHeight * self.LimitN * 4 + winHeight - 960
			end
			self.layer3:setPositionY(temp3)
		end        
	end
	--开启计时器来计算滑动速度
	local function update()
		time = time + 1
	end

	--触摸
	local beginPointY,endPointY,layer1PointY,layer2PointY,layer3PointY
	local flage = false

	local function onTouchBegan(touches,event)
		if IS_GUIDING then
			return
		end
	
		if flage == false then
			beginPointY = touches[1]:getLocation().y
			layer1PointY = self.layer1:getPositionY()
			layer2PointY = self.layer2:getPositionY()
			layer3PointY = self.layer3:getPositionY()

			time = 0
			self:scheduleUpdateWithPriorityLua(update,0)
			flage = true
		end
		return true
	end

	local function onTouchMoved(touches,event)
		if flage == true then
			local location = touches[1]:getLocation()
			local toY = location.y - beginPointY
			--位置改变，判断防止出界
			local temp1 = layer1PointY + toY/4
			if temp1 > 0 then
				temp1 = 0
			elseif temp1 < - bgHeight * self.LimitN + winHeight - 960  then
				temp1 = - bgHeight * self.LimitN + winHeight - 960 
			end
			self.layer1:setPositionY(temp1)

			local temp2 = layer2PointY + toY/2
			if temp2 > 0 then
				temp2 = 0
			elseif temp2 < - bgHeight * self.LimitN / 2 * 4  + winHeight - 960 then
				temp2 = - bgHeight * self.LimitN / 2 * 4 + winHeight - 960 
			end
			self.layer2:setPositionY(temp2)

			local temp3 = layer3PointY + toY
			if temp3 > 0 then
				temp3 = 0
			elseif temp3 < - bgHeight * self.LimitN * 4  + winHeight - 960 then
				temp3 = - bgHeight * self.LimitN * 4 + winHeight - 960 
			end
			self.layer3:setPositionY(temp3)
		end
	end
	local function onTouchEnded(touches,event)
		if flage == true then
			endPointY = touches[1]:getLocation().y
			local len = endPointY - beginPointY
			if time < 40 then
				speed = len / time
				if speed > 60 then
					speed = 60
				elseif speed < -60 then
					speed = -60
				end
				speedTemp = speed
				self:scheduleUpdateWithPriorityLua(scroll,0)
			end
			flage = false
		end
	end
	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCHES_ENDED )    
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	
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
	
	local function showGuide()
		local function guide_2()
			local size = backBTN:getContentSize()
			local pos = backBTN:getWorldPosition()
			pos.y = pos.y + (display.height - 960)
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
		end    
	
	
		local function guide_1()
			local size = cc.size(100, 80)
			local pos = cc.p(500, 190)
			local guide = GuideLayer.new()
			guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
		end

		local guideID = cc.UserDefault:getInstance():getBoolForKey("GUIDE_1", false)
		if guideID == false then
			IS_GUIDING = true
			guide_1()
			return
		end
		
		local guideID = cc.UserDefault:getInstance():getBoolForKey("GUIDE_4", false)
		if guideID == false then
			IS_GUIDING = true
			guide_2()
			return
		end
	end
	performWithDelay(self, showGuide,0.02)
end

return LevelLayer