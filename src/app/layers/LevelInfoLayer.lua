local LevelInfoLayer = class("LevelInfoLayer")

local GuideLayer = require("app.layers.GuideLayer")
IS_GUIDING = false

local function guide(root ,btn)
    local function showGuide()
        local function guide_1()
            local size = btn:getContentSize()
            local pos = btn:getWorldPosition()

            local guide = GuideLayer.new()
            guide:show(root, {mode = 2, pos =pos, size = size})    
        end

        local guideID = cc.UserDefault:getInstance():getBoolForKey("GUIDE_1", false)
        if guideID == false then
            IS_GUIDING = true
            guide_1()
            return
        end
    end
    performWithDelay(root, showGuide,0.02)
end

local function getBossUI(layer)
    local dataLevel = require("tables.dataLevel")
    
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.LEVEL_INFO_BOSS)
    layer:addChild(ui)
    --1攻击  2关闭
    local btn = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Image_15"):getChildByName("Button_17"),
    }
    --1标题  2挑战次数  3信息上   4敌方战力
    local lbl = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Image_15"):getChildByName("Label_16"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Label_19"),
        [3] = ui:getChildByName("Image_18"):getChildByName("Image_22"):getChildByName("Label_23"),
        [4] = ui:getChildByName("Image_18"):getChildByName("Label_31"),
    }
    
    return btn,lbl
end

local function getNormalUI(layer)
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.LEVEL_INFO_NORMAL)
    layer:addChild(ui)

    --1攻击  2关闭
    local btn = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Button_24"),
    }
    --1标题  2挑战次数  3信息上  4敌方战力
    local lbl = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Label_20"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Label_19"),
        [3] = ui:getChildByName("Image_18"):getChildByName("Image_22"):getChildByName("Label_23"),
        [4] = ui:getChildByName("Image_18"):getChildByName("Label_19_0"),
    }
    
    return btn,lbl
end

local function layerLogic(layer,btn,lbl,levelId,isOverLimmit,heroId,battle,isBoss)
    local dataLevel = require("tables.dataLevel")
    local dataUser = require("tables.dataUser")
    local dataUi = require("tables.dataUi")
    local Toast = require("app.layers.Toast")
    local PubDialog = require("app.layers.PubDialog")
    
    local data
    if isOverLimmit == false then
        data = dataLevel.getLevelInfo(levelId)
    else
        data = dataLevel.getLevelInfo(levelId + 100)
    end
    lbl[1]:setString(data.name)
    
    local level
    if isOverLimmit == false then
        level = dataUser.getLevel()
    else
        level = dataUser.getLimitLevel()
    end
    
    if level[levelId] ~= nil then
        lbl[2]:setString(string.format(LANGUAGE_CHINESE.LevelInfoLayer[1],data.timeLimit - level[levelId].dayLimit,data.timeLimit))
        if level[levelId].dayLimit >= data.timeLimit then
            lbl[2]:setColor(cc.c3b(255,0,0))
        end
    end
    
    lbl[3]:setString(data.information)
    lbl[4]:setString(LANGUAGE_CHINESE.LevelInfoLayer[2]..data.enemyPower)
    if battle <= data.enemyPower then
        lbl[4]:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.TintTo:create(1,255,0,0),
            cc.TintTo:create(1,255,255,255)
        )))
    end

    for i = 1,2 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    if IS_GUIDING == true then
                        cc.Director:getInstance():getRunningScene():removeChildByTag(GuideLayer.TAG)        
                        cc.UserDefault:getInstance():setBoolForKey("GUIDE_1", true)
                        cc.UserDefault:getInstance():flush()
                        IS_GUIDING = false 
                        --友盟统计第5步
                        MyApp:umemngEvent(string.format(UMENG_EVENT_ID.EVENT_STEP,5))
                        print("友盟统计第5步")
                    end
                
                    if level[levelId].dayLimit < data.timeLimit then
                        local param = {id = levelId,enemyPower = data.enemyPower,isOverLimmit = isOverLimmit,heroId = heroId,toScene = "MainScene"}
                        if battle > data.enemyPower then
                            --记录挑战关卡
                            local playLevel = dataUser.getPlayLevel()
                            if isOverLimmit == false then
                                playLevel[1] = 2
                            else
                                playLevel[1] = 3
                            end
                            playLevel[playLevel[1]] = levelId
                            dataUser.flushJson()
                            
                            MyApp:enterLoadingScene(param)
                        else
                            layer:addChild(PubDialog:newBattleDialog(param))
                        end
                    else
                        Toast:show(LANGUAGE_CHINESE.LevelInfoLayer[3])
                    end
                elseif i == 2 then
                    layer:removeFromParent(true)
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
    local bossIndex = 1
    if isBoss then
        if not isOverLimmit then
            -- 邪恶龙
            if levelId == 1 then
                bossIndex = 5
            -- 比克大魔王
            elseif levelId == 4 then
                bossIndex = 4
            -- 佛力沙
            elseif levelId == 11 then
                bossIndex = 1
            -- 西鲁
            elseif levelId == 18 then
                bossIndex = 2
            -- 布欧
            elseif levelId == 27 then
                bossIndex = 6
            -- 贝比
            elseif levelId == 37 then
                bossIndex = 3
            -- 邪恶龙
            elseif levelId == 49 then
                bossIndex = 5
            end
        else
            -- 比克大魔王
            if levelId == 2 then
                bossIndex = 4
            -- 佛力沙
            elseif levelId == 4 then
                bossIndex = 1
            -- 西鲁
            elseif levelId == 6 then
                bossIndex = 2
            -- 布欧
            elseif levelId == 9 then
                bossIndex = 6
            -- 贝比
            elseif levelId == 12 then
                bossIndex = 3
            -- 邪恶龙
            elseif levelId == 15 then
                bossIndex = 5
            end
        end
        local x1 = lbl[1]:getParent():getContentSize().width / 2
        local y1 = -lbl[1]:getParent():getContentSize().height / 2
        local x2 = x1
        local y2 = y1
        local x3 = x1
        local y3 = y1
        local scale1 = 0.5
        local scale2 = 0.5
        local t = 3.5

        -- 佛力沙
        if bossIndex ==  1 then
            y1 = y1 + 15
            scale2 = 0.4
            y3 = y3 + 25
            t = 4.1
        -- 西鲁
        elseif bossIndex == 2 then
            scale1 = 0.4
            scale2 = 0.4
            y2 = y2 - 25
            y3 = y3 + 20
            t = 4.2
        -- 贝比
        elseif bossIndex == 3 then
            scale2 = 0.45
            y1 = y1 - 25
            y2 = y2
            y3 = y3 + 10
            t = 3.7
        -- 比克大魔王
        elseif bossIndex == 4 then
            y1 = y1 - 10
            y2 = y2 - 15
            y3 = y3 + 20
            t = 3.5
        -- 邪恶龙
        elseif bossIndex == 5 then
            scale1 = 0.4
            y1 = y1 - 20
            scale2 = 0.4
            y3 = y3 + 10
            t = 3.7
        -- 布欧
        elseif bossIndex == 6 then
            y1 = y1 - 20
            y3 = y3 + 20
            t = 3.7
        end
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b" .. bossIndex .. "0.png", "armatures/b" .. bossIndex .. "0.plist", "armatures/b" .. bossIndex .. ".ExportJson")
        local boss1 = ccs.Armature:create("b" .. bossIndex)
        boss1:setScale(scale1)
        lbl[1]:getParent():addChild(boss1, 100)
        boss1:setPosition(x1, y1)
        boss1:getAnimation():playWithIndex(1)
        
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("armatures/b" .. bossIndex .. "_10.png", "armatures/b" .. bossIndex .. "_10.plist", "armatures/b" .. bossIndex .. "_1.ExportJson")
        local boss2 = ccs.Armature:create("b" .. bossIndex .. "_1")
        boss2:setScale(scale2)
        lbl[1]:getParent():addChild(boss2, 101)
        boss2:setPosition(x2, y2)
        boss2:setOpacity(0)
        boss2:getAnimation():playWithIndex(1)
        
        if not isOverLimmit and levelId == 1 then
            boss1:setVisible(false)
            boss2:setOpacity(255)
            boss2:getAnimation():playWithIndex(0)
            boss2:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function ()
                        boss2:getAnimation():playWithIndex(2)
                    end),
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function ()
                        boss2:getAnimation():playWithIndex(0)
                    end),
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function ()
                        boss2:getAnimation():playWithIndex(1)
                    end)
                )
            )
        else
            performWithDelay(lbl[1]:getParent(), 
                function ()
                    -- 第一形态
                    boss1:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.4),
                            cc.FadeOut:create(0.6),
                            cc.CallFunc:create(function ()
                                boss1:setVisible(false)
                                boss1:setOpacity(255)
                            end)
                        )
                    )

                    -- 第二形态
                    boss2:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.4),
                            cc.CallFunc:create(function ()
                                boss2:setOpacity(255)
                            end),
                            cc.ScaleTo:create(0.4, scale2 * 1.1),
                            cc.ScaleTo:create(0.2, scale2 * 1),
                            cc.DelayTime:create(1),
                            cc.CallFunc:create(function ()
                                boss2:getAnimation():playWithIndex(2)
                            end),
                            cc.DelayTime:create(0.5),
                            cc.CallFunc:create(function ()
                                boss2:getAnimation():playWithIndex(0)
                            end),
                            cc.DelayTime:create(0.5),
                            cc.CallFunc:create(function ()
                                boss2:getAnimation():playWithIndex(1)
                            end)
                        )
                    )

                    -- boss剪影
                    local jianying
                    local apY = 0.5
                    local jyScale = 1.8
                    -- 佛力沙
                    if "boss" .. bossIndex .. "_2" == "boss1_2" then
                        jianying = "feili"
                        apY = 0.35
                        -- 西鲁
                    elseif "boss" .. bossIndex .. "_2" == "boss2_2" then
                        jianying = "shalu"
                        apY = 0.24
                        -- 贝比
                    elseif "boss" .. bossIndex .. "_2" == "boss3_2" then
                        jianying = "beibi"
                        apY = 0.4
                        -- 比克大魔王
                    elseif "boss" .. bossIndex .. "_2" == "boss4_2" then
                        jianying = "bike"
                        apY = 0.3
                        -- 一星邪恶龙
                    elseif "boss" .. bossIndex .. "_2" == "boss5_2" then
                        jianying = "shenlong"
                        jyScale = 1.4
                        -- 魔人布欧
                    elseif "boss" .. bossIndex .. "_2" == "boss6_2" then
                        jianying = "moren"
                        apY = 0.38
                    end
                    if jianying then
                        cc.SpriteFrameCache:getInstance():addSpriteFrames("images/bossbiansheng.plist", "images/bossbiansheng.pvr.ccz")
                        jianying = cc.Sprite:createWithSpriteFrameName(jianying .. ".png")
                        jianying:setAnchorPoint(0.5, apY)
                        boss2:addChild(jianying, 200)
                        jianying:setScale(1.1 * jyScale * 4)
                        jianying:setVisible(false)
                        jianying:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.6),
                                cc.CallFunc:create(function ()
                                    jianying:setVisible(true)
                                end),
                                cc.DelayTime:create(0.2),
                                cc.Spawn:create(
                                    cc.ScaleTo:create(0.2, jyScale * 4)
                                    ,cc.FadeOut:create(0.2)
                                )
                                ,cc.RemoveSelf:create()
                            )
                        )

                        -- 收光特效
                        local sfs = {}
                        for i = 1, 8 do
                            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bbssg_" .. i .. ".png")
                        end
                        local animation = cc.Animation:createWithSpriteFrames(sfs, 0.1)
                        local animate = cc.Animate:create(animation)
                        local shouguang = cc.Sprite:create()
                        shouguang:setAnchorPoint(0.5, 0.4)
                        shouguang:setScale(8)
                        shouguang:runAction(
                            cc.Sequence:create(
                                animate,
                                cc.RemoveSelf:create()
                            )
                        )
                        boss1:addChild(shouguang, 201)

                        -- 爆炸特效
                        local sfs = {}
                        for i = 1, 8 do
                            sfs[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bbsbz_" .. i .. ".png")
                        end
                        local animation = cc.Animation:createWithSpriteFrames(sfs, 0.1)
                        animation:setLoops(-1)
                        local animate = cc.Animate:create(animation)
                        local baozha = cc.Sprite:create()
                        baozha:setVisible(false)
                        baozha:setAnchorPoint(0.5, 0.4)
                        baozha:setScale(8)
                        baozha:runAction(
                            animate
                        )
                        baozha:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.7),
                                cc.CallFunc:create(function ()
                                    baozha:setVisible(true)
                                end),
                                cc.DelayTime:create(0.8),
                                cc.RemoveSelf:create()
                            )
                        )
                        boss2:addChild(baozha, 201)
                    end
                end
                , 1)
        end
    end
    
    guide(cc.Director:getInstance():getRunningScene() ,btn[1])
end


function LevelInfoLayer:newBossLayer(id,isOverLimmit,heroId,battle)
    local layer = cc.Layer:create()
    
    local btn,lbl = getBossUI(layer)
    layerLogic(layer,btn,lbl,id,isOverLimmit,heroId,battle, true)
    
    return layer
end

function LevelInfoLayer:newNormalLayer(id,isOverLimmit,heroId,battle)
    local layer = cc.Layer:create()

    local btn,lbl = getNormalUI(layer)
    layerLogic(layer,btn,lbl,id,isOverLimmit,heroId,battle)

    return layer
end


return LevelInfoLayer