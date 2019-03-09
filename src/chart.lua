-- build in 2014/1/31
-- author vincent ho

Chart = {}
Chart.SERVER = "http://api.910app.com/mini_game/score"
Chart.PACKAGE_NAME = "mobi.shoumeng.cjsyr"

local Toast = require "app.layers.Toast"

-- 获取设备ID
local function getDeviceID()
    return MyApp:getDeviveId()
end

-- 向服务端提交数据
local function submitData(data, handler)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", Chart.SERVER)
    local xhrState = false
    local isReturn = false
    local function onReadyStateChange()
        xhrState = true
        local response = xhr.response
--        print("response = " .. response)
        
        if response == nil then
            handler("nil")
        else
            local output = json.decode(response)
            if not isReturn then
                isReturn = true
                handler(output)
            end
        end
        
        
    end
    xhr:registerScriptHandler(onReadyStateChange)
    data.package_name = Chart.PACKAGE_NAME
    xhr:send(json.encode(data))
    
    performWithDelay(cc.Director:getInstance():getRunningScene(), function ()
        if not isReturn then
            isReturn = true
            handler(false)
            Toast:show("网络异常")
        end
    end, 3)
end

-- 测试成功
function Chart.getChart(handle)
	local data = {
        command = "get_chart",
        user_id = getDeviceID(),
	}
	local function func(parameters)
	    if parameters then
            table.sort(parameters.top20, function (a, b) return a.user_position < b.user_position end)   
	    end
        handle(parameters)
	end
    submitData(data, func)
end

-- 测试成功
function Chart.createUser(handle)
    local data = {
        command = "create_user",
        user_id = getDeviceID(),
    }
    submitData(data, handle)
end

-- 测试成功
function Chart.userRename(newName, handle)
    local data = {
        command = "user_rename",
        user_id = getDeviceID(),
        user_new_name = newName
    }
    submitData(data, handle)
end

-- 测试成功
function Chart.submitUserData(data, handle)
	local data = {
        command = "submit_user_data",
        user_id = getDeviceID(),
        user_power = data.userPower,
        user_score = data.userScore
	}
    submitData(data, handle)
end

function Chart.submitMMActivity(data, handle)
	local data = {
        command = "submit_mm_activity",
        user_id = getDeviceID(),
        user_real_name = data.userRealName,
        user_phone = data.userPhone,
        user_qq = data.userQQ
    }
    submitData(data, handle)
end



---------------------- AI数据 ----------------------------
-- 首次创建AI数据
function Chart.creatAIChart()
	local dataEndless = require "tables.dataEndlessLevel"
    local data = dataEndless.getAIChart()
    local function handle(parameters)
    	if parameters then
            print("创建用户成功！")
            print("用户名 = " .. parameters.user_name)
            print("名次 = " .. parameters.user_position)
            print("历史最高分 = " .. parameters.user_position)
        else
            print("创建用户失败！")
    	end
    end
    for i, v in ipairs(data) do
        local d = {
            command = "create_user",
            user_id = tostring(v.deviceID)
        }
        print("v.deviceID = " .. v.deviceID)
        submitData(d, handle)
    end
end
--Chart.creatAIChart()

-- 修改AI数据，改名
function Chart.renameAIChart()
    local dataEndless = require "tables.dataEndlessLevel"
    local data = dataEndless.getAIChart()
    local function handle(parameters)
        if parameters then
            if parameters.is_succeed then
                print("用户名修改成功！")
            else
                print("创建用户失败！")
            end
        end
    end
    for i, v in ipairs(data) do
        local d = {
            command = "user_rename",
            user_id = tostring(v.deviceID),
            user_new_name = v.name
        }
        submitData(d, handle)
    end
end
--Chart.renameAIChart()

-- 提交AI用户数据
function Chart.submitAIChart()
    local dataEndless = require "tables.dataEndlessLevel"
    local data = dataEndless.getAIChart()
    local function handle(parameters)
    end
    for i, v in ipairs(data) do
        local d = {
            command = "submit_user_data",
            user_id = tostring(v.deviceID),
            user_power = v.power,
            user_score = v.score
        }
        submitData(d, handle)
    end
end
--Chart.submitAIChart()

-- 获取AI排行榜
function Chart.getAIChart()
    local function handle(parameters)
        if parameters then
            table.sort(parameters.top20, function (a, b) return a.user_position < b.user_position end)
            for i, v in ipairs(parameters.top20) do
                print("第" .. v.user_position .. "名:: 名字：" .. v.user_name .. ", 战斗力：" .. v.user_power .. ", 分数：" .. v.user_score)
            end
        end
    end
    local data = {
        command = "get_chart",
        user_id = "vincentho"
    }
    submitData(data, handle)
end
--Chart.getAIChart()