local AchievementLayer = class("AchievementLayer",function()
	return cc.Layer:create()
end)

function AchievementLayer:ctor()
	local task = require("tables.dataUi")
	local dataUser = require("tables.dataUser")
	local Toast = require("app.layers.Toast")

	local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)
	local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.ACHIEVEMENTlAYER_LAYER_UI)
	self:addChild(ui)
	
	--返回
	local btn = {
		[1] = ui:getChildByName("Button_61"),
	}
	
	local list = ui:getChildByName("ListView_155")
	list:setContentSize(cc.size(list:getContentSize().width, display.height - 230))   
	
	local dispatcher = self:getEventDispatcher()
	local achieve = task.getAchievement()
	local t = dataUser.getTask()
	
	local function newOneItem(p_data)
		local item = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.ACHIEVEMENTlAYER_LAYER_LIST_UI)
		
		--领取
		local btn = item:getChildByName("Image_52"):getChildByName("Button_57")
		--1内容  2奖励
		local lbl = {
			[1] = item:getChildByName("Image_52"):getChildByName("Label_53"),
			[2] = item:getChildByName("Image_52"):getChildByName("Label_56"),
		}
		--1领取  2领取pressed 3已完成  4未完成
		local img = {
			[1] = item:getChildByName("Image_52"):getChildByName("Button_57"):getChildByName("Image_59"),
			[2] = item:getChildByName("Image_52"):getChildByName("Button_57"):getChildByName("Image_59_0"),
			[3] = item:getChildByName("Image_52"):getChildByName("Image_63"),
			[4] = item:getChildByName("Image_52"):getChildByName("Image_63_0"),
			[5] = item:getChildByName("Image_52"):getChildByName("Button_57"):getChildByName("Image_58"),
		}

		img[2]:setVisible(false)
		img[3]:setVisible(false)
		img[4]:setVisible(false)
		
		local function btnUp()
			img[5]:setVisible(true)
			img[1]:setVisible(true)
			img[2]:setVisible(false)
		end
		btnUp()
		local function btnDown()
			img[5]:setVisible(false)
			img[1]:setVisible(false)
			img[2]:setVisible(true)
		end

		--成就完成
		local function showFinalInfo()
			lbl[1]:setString(LANGUAGE_CHINESE.AchievementLayer[5])
			lbl[2]:setVisible(false)
			btn:setVisible(false)
		end

		--获取各种类任务总数
		local function getTotalTask()
			local total = {}
			for i,v in pairs(achieve) do
				if total[v.type] == nil then
					total[v.type] = 1
				else
					total[v.type] = total[v.type] + 1
				end
			end
			return total
		end
		local total = getTotalTask()
		
		--根据ID展示信息
		local function showInfo(pp_data)
			local data = achieve[pp_data]
			if data == nil then
				data = achieve[pp_data - 1]
				btn:setVisible(false)
				img[3]:setVisible(true)
			end
			
			if data.type == 1 then
				lbl[1]:setString(string.format(LANGUAGE_CHINESE.AchievementLayer[1],data.passStar,data.level))
			elseif data.type == 2 then
				lbl[1]:setString(string.format(LANGUAGE_CHINESE.AchievementLayer[1],data.passStar,data.level))
			elseif data.type == 3 then
				lbl[1]:setString(string.format(LANGUAGE_CHINESE.AchievementLayer[2],data.killEnemy))
			elseif data.type == 4 then
				lbl[1]:setString(string.format(LANGUAGE_CHINESE.AchievementLayer[3],data.consolidate))
			elseif data.type == 5 then
				lbl[1]:setString(string.format(LANGUAGE_CHINESE.AchievementLayer[4],data.upgrade))
			end
			lbl[2]:setString(data.describe)
		end
		showInfo(p_data)
		
		local levelData = dataUser.getLevel()
		local data = achieve[p_data]
		--type为1 2的逻辑       param:存档表的字段名，配置表的开始索引,是否设置按钮可见
		local function btnLogic1(p_task,n,isBtnVisible)
			local t = dataUser.getTask()
			if t[p_task] < getTotalTask()[data.type] + n then
				local p = achieve[t[p_task]]
				if isBtnVisible == false then
					if levelData[p.level].star >= p.passStar then
						dataUser.increaseGold(data.reward)
						t[p_task] = t[p_task] + 1
						showInfo(t[p_task])
						dataUser.flushJson()
						self:getParent():getChildByName("TopLayer"):fresh()
						Toast:show(string.format(LANGUAGE_CHINESE.AchievementLayer[6],data.reward))
					else
						Toast:show(LANGUAGE_CHINESE.AchievementLayer[7])
					end
				elseif isBtnVisible == true then
					if levelData[p.level].star < p.passStar then
						img[4]:setVisible(true)
						btn:setVisible(false)
					end
				end 
			elseif t[p_task] == getTotalTask()[data.type] + n and isBtnVisible == false then
				dataUser.increaseGold(data.reward)
				t[p_task] = t[p_task] + 1
				showInfo(t[p_task])
				dataUser.flushJson()
				self:getParent():getChildByName("TopLayer"):fresh() 
			end
		end
		--3 4 5的逻辑   任务类型，起始位置，字段名,是否设置按钮可见
		local function btnLogic2(p_task,n,str,isBtnVisible)
			local t = dataUser.getTask()
			local p = achieve[t[p_task].id] 
			if t[p_task].id < getTotalTask()[data.type] + n then
				if isBtnVisible == false then
					if t[p_task][str] >= p[str] then
						dataUser.increaseGold(data.reward)
						t[p_task].id = t[p_task].id + 1
						showInfo(t[p_task].id)
						dataUser.flushJson()
						self:getParent():getChildByName("TopLayer"):fresh()
						Toast:show(string.format(LANGUAGE_CHINESE.AchievementLayer[6],data.reward))
					else
						Toast:show(LANGUAGE_CHINESE.AchievementLayer[8])
					end
				elseif isBtnVisible == true then
					if t[p_task][str] < p[str] then
						img[4]:setVisible(true)
						btn:setVisible(false)
					end
				end
			elseif t[p_task].id == getTotalTask()[data.type] + n and isBtnVisible == false then
				dataUser.increaseGold(data.reward)
				t[p_task].id = t[p_task].id + 1
				showInfo(t[p_task].id)
				dataUser.flushJson()
				self:getParent():getChildByName("TopLayer"):fresh() 
			end
		end
		
		if data ~= nil then
			if data.type == 1 then
				btnLogic1("task1",0,true)
			elseif data.type == 2 then
				btnLogic1("task2",100,true)
			elseif data.type == 3 then
				btnLogic2("task3",300,"killEnemy",true)
			elseif data.type == 4 then
				btnLogic2("task4",500,"consolidate",true)
			elseif data.type == 5 then
				btnLogic2("task5",600,"upgrade",true)
			end
		end
		
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if data.type == 1 then
					btnLogic1("task1",0,false)
					btnLogic1("task1",0,true)
				elseif data.type == 2 then
					btnLogic1("task2",100,false)
					btnLogic1("task2",100,true)
				elseif data.type == 3 then
					btnLogic2("task3",300,"killEnemy",false)
					btnLogic2("task3",300,"killEnemy",true)
				elseif data.type == 4 then
					btnLogic2("task4",500,"consolidate",false)
					btnLogic2("task4",500,"consolidate",true)
				elseif data.type == 5 then
					btnLogic2("task5",600,"upgrade",false)
					btnLogic2("task5",600,"upgrade",true)
				end
				btnUp()
			elseif type == ccui.TouchEventType.began then
				btnDown()
			end
		end
		btn:addTouchEventListener(onBtn)
		
		return item
	end
	
	list:pushBackCustomItem(newOneItem(t.task1))
	list:pushBackCustomItem(newOneItem(t.task2))
	list:pushBackCustomItem(newOneItem(t.task3.id))
	list:pushBackCustomItem(newOneItem(t.task4.id))
	list:pushBackCustomItem(newOneItem(t.task5.id))
	
	for i = 1,1 do
		local function onBtn(sender,type)
			if type == ccui.TouchEventType.ended then
				AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
				if i == 1 then
					MyApp:enterIndexScene()
				end
			end
		end
		btn[i]:addTouchEventListener(onBtn)
	end
	
	local eventDispatcher = self:getEventDispatcher()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local kListener = cc.EventListenerKeyboard:create()
		kListener:registerScriptHandler(function(keyCode, event)
			if keyCode == 6 then
				MyApp:enterIndexScene()
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED )
		eventDispatcher:addEventListenerWithSceneGraphPriority(kListener, self)
	end
end

return AchievementLayer