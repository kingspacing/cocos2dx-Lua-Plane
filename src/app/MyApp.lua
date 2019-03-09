MyApp = {}

function MyApp:run()
--    self:enterLoadingScene({id = 1,enemyPower = 1,isOverLimmit = true,heroId = 1,isBattle = true})
	self:enterWelcomeScene()

end

--战斗界面
function MyApp:enterMainScene(param)
	MyApp:toScene(require("app.scenes.MainScene").new(param))
end

--无尽模式
function MyApp:enterEndlessScene(param)
	MyApp:toScene(require("app.scenes.EndlessMainScene").new(param))
end

--首页界面
function MyApp:enterIndexScene(param)
	MyApp:toScene(require("app.scenes.IndexScene").new(param))
end

--展示界面
function MyApp:enterShowScene()
	MyApp:toScene(require("app.scenes.ShowScene").new())
end

--充值界面
function MyApp:enterRechargeScene()
	MyApp:toScene(require("app.scenes.RechargeScene").new())
end

--任务界面
function MyApp:enterAchievementScene()
	MyApp:toScene(require("app.scenes.AchievementScene").new())
end

--关卡界面
function MyApp:enterLevelScene(param)
	MyApp:toScene(require("app.scenes.LevelScene").new(param))
end

--胜利界面
function MyApp:enterWinScene(param)
	MyApp:toScene(require("app.scenes.WinScene").new(param))
end

--欢迎界面
function MyApp:enterWelcomeScene()
	MyApp:toScene(require("app.scenes.WelcomeScene").new())
end

--加载界面
function MyApp:enterLoadingScene(param)
	MyApp:toScene(require("app.scenes.LoadingScene").new(param))
end

--无尽结算
function MyApp:enterEndlessWinScene(param)
	MyApp:toScene(require("app.scenes.EndlessWinScene").new(param))
end

--排行界面
function MyApp:enterRankingScene(param)
	MyApp:toScene(require("app.scenes.RankingScene").new(param))
end

isEnter = false
--场景跳转方法
function MyApp:toScene(scene)
	if isEnter == true then
		return
	end
	isEnter = true
	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5,scene, display.COLOR_BLACK))
	else
		cc.Director:getInstance():runWithScene(scene)
	end
end

local payTime = 0
local backTime = 0
--开始支付
function MyApp:pay(id)
   payBack(id)
--[[
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		payTime = os.clock()
	
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "sendString"
		local javaParams = {
			id
		}
		
		local javaMethodSig = "(Ljava/lang/String;)V"
		LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		
	elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE then 
		local args = { payId = id }
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "AppController"
		local function callback(param)
			if "success" == param then
				payBack(id)
			end
		end
		luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
		local ok,ret  = luaoc.callStaticMethod(className,"pay",args) 
	else
		payBack(id)
	end
--]]
end

--支付回调
function payBack(id)
	print("------payback:[" .. id .. "]")
--[[
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
		backTime = os.clock()
--        if backTime - payTime < 0.5 then
--            return
--        end
	end
--]]
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local event = cc.EventCustom:new("pay_result")
	event._usedata = id
	eventDispatcher:dispatchEvent(event)
end

--退出游戏
function toEnd()
	cc.Director:getInstance():endToLua() 
end

--退出游戏
function MyApp:exit()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "sendString"
		local javaParams = {
			"exit"
		}

		local javaMethodSig = "(Ljava/lang/String;)V"
		LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	end
end

--友盟事件统计
function MyApp:umemngEvent(id)
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "umengEvent"
		local javaParams = {id}
		local javaMethodSig = "(Ljava/lang/String;)V"
		LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	end
end

--友盟关卡事件统计
function MyApp:umengLevelEvent(event, level)
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "umengLevelEvent"
		local javaParams = {event, tostring(level)}
		local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
		LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	end
end

--获取版本号码
function MyApp:getVersion()
	--[[
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "getVersionCode"
		local javaParams = {

			}
		local javaMethodSig = "()I"
		local ok, ret = LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		return tonumber(ret)
	end
	--]]
	return 1
end
--判断是否联网
function MyApp:isConnect()
	-- if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
	--     local javaClassName = "org.cocos2dx.lua.AppActivity"
	--     local javaMethodName = "isConnect"
	--     local javaParams = {

	--         }
	--     local javaMethodSig = "()Z"
	--     local ok, ret =LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	--     return ret
	-- else 
	--     return true
	-- end
	local network = require("framework.network")
	if network.getInternetConnectionStatus() == kCCNetworkStatusNotReachable then
		return false
	end
	return true
end

--获取设备ID
function MyApp:getDeviveId()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "getDeviveId"
		local javaParams = {

			}
		local javaMethodSig = "()Ljava/lang/String;"
		local ok, ret =LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		return ret
	else 
		return "test34"
	end
end
--设置定时弹出通知
function MyApp:setAlarmNotif(t)
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "setAlarmNotif"
		local javaParams = {
			t
		}
		local javaMethodSig = "(I)V"
		LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	end
end
--获取签名证书字符串
function MyApp:getKeyId()
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then 
		local javaClassName = "org.cocos2dx.lua.AppActivity"
		local javaMethodName = "getKeyId"
		local javaParams = {

			}
		local javaMethodSig = "()Ljava/lang/String;"
		local ok, ret =LuaJavaBridge.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		return ret
	else 
		return "test"
	end
end

return MyApp