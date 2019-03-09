local dataUser = {}

dataUser.user_data = {
    --金币
    gold = 10000,
    --护盾，炸弹，龙珠数，龙珠星级
    shield = 2,
    boom = 2,
    ball = 0,
    ballLevel = {[1] = false,[2] = false,[3] = false,[4] = false,[5] = false,[6] = false,[7] = false},
    --幸运转盘龙珠的血量和攻击加成
    attack = 1,
    life = 1,
    --是否拥有英雄以及数据
    hero = {
        [1] = {isHave = true,star = 1,level = 0},
        [2] = {isHave = false,star = 2,level = 0},
        [3] = {isHave = false,star = 5,level = 0},
    },
    heroID = 1,
    --普通关卡
    level = {
        --第几关几星过图
        [1] = {star = 0,dayLimit = 0}
    --...
    },
    --极限关卡
    limitLevel = {
        --第几关几星过图
        [1] = {star = 0,dayLimit = 0}
    },
    --是否第一次通关
    isFirstPass = false,
    --世界地图锁定关卡  
    playLevel = {
        --当前模式的id
        [1] = 2,
        --普通第几关
        [2] = 1,
        --极限第几关
        [3] = 1,
    },
    --进入游戏弹礼包
    gift = {
        --重新进入游戏
        onceIn = true,
        --第一次进入游戏
        initGift = true,
        --购买次数
        buyTime = 0,
    },
    --任务 (累计)
    task = {
        --当前ID
        task1 = 1,
        task2 = 101,
        --当前ID和击杀个数
        task3 = {id = 301,killEnemy = 0},
        task4 = {id = 501,consolidate = 0},
        task5 = {id = 601,upgrade = 0},
    },
    -- 激活码
    licence = {},
    --上次离线的日期
    daily = {day = 0},
    -- 购买大礼包存档，玩家未购买过大礼包，从第四关卡开始，第一次进入关卡弹出超值礼包
    buyGift = {},
    --无尽模式道具
    endlessShop = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0},
    --排行榜存档
    ranking = {power = 0,score = 0,rank = 0,real_name = 0,phone = 0,QQ = 0},
}

function dataUser.readPlayerDataFromFile()
    local file = io.open(cc.FileUtils:getInstance():getWritablePath().."data5.dat", "r")
    require("json")
    local jsondata = file:read("*all")
    dataUser.user_data = json.decode(jsondata)
    file:close()
--    dataUser.readData()
end

function dataUser.writePlayerData2File()
    -- 存档兼容处理
    if not dataUser.user_data.buyGift then
        dataUser.user_data.buyGift = {}
    end
    if dataUser.user_data.ball == nil then
        dataUser.user_data.ball = 0
    end
    if dataUser.user_data.ballLevel == nil then
        dataUser.user_data.ballLevel = {[1] = false,[2] = false,[3] = false,[4] = false,[5] = false,[6] = false,[7] = false}
    end
    if dataUser.user_data.attack == nil then
        dataUser.user_data.attack = 1
        dataUser.user_data.life = 1
    end

    local file = io.open(cc.FileUtils:getInstance():getWritablePath().."data5.dat", "w")
    require("json")
    local jsondata = json.encode(dataUser.user_data)
    file:write(jsondata)
    file:close()
end

function dataUser.flushJson()
    dataUser.writePlayerData2File()
    dataUser.readPlayerDataFromFile()
end

--测试数据
local function initDataUser()
    local flag
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
        if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath() .. "data5.dat") then
            flag = false
        else
            flag = true
        end
    else
        flag = cc.UserDefault:getInstance():getBoolForKey("FirstIn",true)
    end
    if flag == true then
        cc.UserDefault:getInstance():setBoolForKey("FirstIn",false)
        cc.UserDefault:getInstance():flush()
        dataUser.writePlayerData2File()
    else
        dataUser.readPlayerDataFromFile()
        
        if dataUser.user_data.endlessShop == nil then
            dataUser.user_data.endlessShop = {[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0}
            dataUser.user_data.ranking = {power = 0,score = 0,rank = 0,real_name = 0,phone = 0,QQ = 0}
        end
        
        dataUser.user_data.gift.initGift = false
        dataUser.flushJson()
    end
end

initDataUser()

--增加金币
function dataUser.increaseGold(n)
    dataUser.user_data.gold = dataUser.user_data.gold + n
end

--获取金币
function dataUser.getGold()
    return dataUser.user_data.gold
end

function dataUser.getTask()
    return dataUser.user_data.task
end

function dataUser.getHero()
    return dataUser.user_data.hero
end

function dataUser.getLevel()
    return dataUser.user_data.level
end

function dataUser.getLimitLevel()
    return dataUser.user_data.limitLevel
end

function dataUser.increaseShield(n)
    dataUser.user_data.shield = dataUser.user_data.shield + n
end

function dataUser.increaseBoom(n)
    dataUser.user_data.boom = dataUser.user_data.boom + n
end

function dataUser.increaseBall(n)
    dataUser.user_data.ball = dataUser.user_data.ball + n
end

function dataUser.setAttack(n)
    dataUser.user_data.attack = n
end

function dataUser.setLife(n)
    dataUser.user_data.life = n
end

function dataUser.getAttack()
    return dataUser.user_data.attack
end

function dataUser.getLife()
    return dataUser.user_data.life
end

function dataUser.getShield()
    return dataUser.user_data.shield
end

function dataUser.getBoom()
    return dataUser.user_data.boom
end

function dataUser.getBall()
    return dataUser.user_data.ball
end

function dataUser.getBallLevel()
    return dataUser.user_data.ballLevel
end

function dataUser.setHeroID(n)
    dataUser.user_data.heroID = n
end

function dataUser.getHeroID()
    return dataUser.user_data.heroID
end

function dataUser.getDaily()
    return dataUser.user_data.daily
end

function dataUser.getFirstPass()
    return dataUser.user_data.isFirstPass
end

function dataUser.changeFirstPass(boo)
    dataUser.user_data.isFirstPass = boo
end

function dataUser.getGift()
    return dataUser.user_data.gift
end

function dataUser.getPlayLevel()
    return dataUser.user_data.playLevel
end

-- 增加激活码
function dataUser.increaseLicence(parameters)
	dataUser.user_data.licence[parameters] = true
    dataUser.flushJson()
end
-- 获取激活码
function dataUser.getLicence(parameters)
    return dataUser.user_data.licence
end

-- 购买礼包设置信息
function dataUser.setBuyGift(levelID)
	dataUser.user_data.buyGift[levelID] = true
    dataUser.flushJson()
end
-- 购买礼包获取信息
function dataUser.getBuyGift(levelID)
    return dataUser.user_data.buyGift[levelID]
end

--无尽模式存物品
function dataUser.getEndlessShop()
    return dataUser.user_data.endlessShop
end
--排行榜
function dataUser.getRanking()
    return dataUser.user_data.ranking
end

return dataUser