cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"
-- require ("framework.init")

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

--获取版本号码
local function getVersion()
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

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    local FLAG_FILENAME = "main.lua" -- 以此文件名为标记来获取当前文件路径
    local SOURCE_ROOTNAME = "src" -- 代码根目录
    local RESOURCE_ROOTNAME = "res" -- 资源根目录


    local fullpath = cc.FileUtils:getInstance():fullPathForFilename(SOURCE_ROOTNAME .. "/" .. FLAG_FILENAME)
    local index = string.find(fullpath,FLAG_FILENAME) - 1
    local srcDict = string.sub(fullpath,0,index)
    index = string.find(fullpath, SOURCE_ROOTNAME) - 1
    local resDict = string.sub(fullpath,0,index) .. RESOURCE_ROOTNAME
    cc.FileUtils:getInstance():addSearchPath(srcDict);
    cc.FileUtils:getInstance():addSearchPath(resDict);
    cc.FileUtils:getInstance():addSearchResolutionsOrder(SOURCE_ROOTNAME);
    cc.FileUtils:getInstance():addSearchResolutionsOrder(RESOURCE_ROOTNAME);

    local assetsManager = cc.AssetsManager:new("http://update.starwars.910app.com/dragonball/package.zip",
        "http://update.starwars.910app.com/dragonball/versioncode.txt",
        pathToSave)
    local version = assetsManager:getVersion()

    if version ~= "" and getVersion() < tonumber(version)  then 
        local paths = cc.FileUtils:getInstance():getSearchPaths()
        table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath() .. "src")
        table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath() .. "res")
        table.insert(paths,1,  cc.FileUtils:getInstance():getWritablePath())
        cc.FileUtils:getInstance():setSearchPaths(paths)
    end
    
--    for key, var in ipairs(cc.FileUtils:getInstance():getSearchPaths()) do
--        print(var)
--    end

    require("app.MyApp")
    MyApp:run()
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
