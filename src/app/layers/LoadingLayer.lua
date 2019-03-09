local LoadingLayer = class("LoadingLayer",function()
    return cc.Layer:create()
end)

function LoadingLayer:ctor(param)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/commonUI/common.plist","ui/commonUI/common.pvr.ccz")

    local girl = cc.Sprite:createWithSpriteFrameName("NPC.png")
    girl:setPosition(display.cx - 130,display.cy + 125)
    self:addChild(girl)

    local kuang = cc.Sprite:createWithSpriteFrameName("jz2Pic12.png")
    kuang:setPosition(display.cx,display.cy - 50)
    self:addChild(kuang)

    for i = 1,11 do
        local sp = cc.Sprite:createWithSpriteFrameName("jz2Pic"..i..".png")
        sp:setPosition(50 * i,55)
        kuang:addChild(sp)

        local function action()
            sp:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(0.2,cc.p(0,20)),
                cc.MoveBy:create(0.2,cc.p(0,-20)),
                cc.DelayTime:create(2)
            )))
        end
        performWithDelay(sp,action,0.3*i)
    end
    self:registerScriptHandler(function(event)
        if "enterTransitionFinish" == event then
            performWithDelay(self,function()
                ccs.ArmatureDataManager:destroyInstance()
                ccs.GUIReader:destroyInstance()
                cc.Director:getInstance():purgeCachedData()
                local resFiles
                local resImages

                local function loadResource_1()
                    resFiles = {
                        "images/bullet.plist",       -- 子弹
                        "images/enemy.plist",        -- 敌机
                        "images/hit.plist",          -- 击中
                        "images/bb.plist",           -- 必杀
                        "images/hudun.plist",          -- 护盾
                        "ui/indexScene/indexScene_ani.plist", -- boss暴气
                        GAME_IMAGE.MAIN_SCENE_UI_FILE,
                        "ui/commonUI/common.plist",
                        "images/bg.plist",
                        "ui/guide/guideRes.plist",            --guide
                        "ui/main_ui.plist"
                    }

                    resImages = {
                        "images/bullet.pvr.ccz",
                        "images/enemy.pvr.ccz",
                        "images/hit.pvr.ccz",
                        "images/bb.pvr.ccz",
                        "images/hudun.pvr.ccz",
                        "ui/indexScene/indexScene_ani.pvr.ccz",
                        GAME_IMAGE.MAIN_SCENE_UI_IMG,
                        "ui/commonUI/common.pvr.ccz",
                        "images/bg.pvr.ccz",
                        "ui/guide/guideRes.png",            --guide
                        "ui/main_ui.png",
                    }
                    
                    print"load"
                end

                local function loadResource_2()
                    resFiles = {
                        GAME_ANIM.INDEX_SCENE_ANI_FILE,              -- 强化进阶
                        GAME_ANIM.INDEX_SCENE_ANI_BAOQI_FILE,        -- 爆气
                        GAME_IMAGE.INDEX_SCENE_UI_FILE,              -- 主界面UI
                        [4] = GAME_IMAGE.LEVEL_SCENE_UI_FILE,
                        [5] = "ui/levelScene/item_animat.plist",
                        [6] = "ui/commonUI/common.plist",
                        [7] = "ui/guide/guideRes.plist"            --guide
                    }

                    resImages = {
                        GAME_ANIM.INDEX_SCENE_ANI_IMG,
                        GAME_ANIM.INDEX_SCENE_ANI_BAOQI_IMG,
                        GAME_IMAGE.INDEX_SCENE_UI_IMG,
                        [4] = GAME_IMAGE.LEVEL_SCENE_UI_IMG,
                        [5] = "ui/levelScene/item_animat.pvr.ccz",
                        [6] = "ui/commonUI/common.pvr.ccz",
                        [7] = "ui/guide/guideRes.png"            --guide
                    }
                    for i = 0,3 do
                        resFiles[i+8] = "ui/index_ui"..i..".plist"
                        resImages[i+8] = "ui/index_ui"..i..".png"
                    end
                end

                local function LoadAni()
                    -- 加载动画
                    -- 击中
                    local spriteFrames = {}
                    for i = 1, 5 do
                        spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("hit" .. i .. ".png")
                    end
                    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
                    cc.AnimationCache:getInstance():addAnimation(animation, "hit")

                    -- 护盾
                    local spriteFrames = {}
                    for i = 1, 4 do
                        spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("hudun_" .. i .. ".png")
                    end
                    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
                    cc.AnimationCache:getInstance():addAnimation(animation, "hudun")

                    -- 必杀
                    local spriteFrames = {}
                    for i = 1, 3 do
                        spriteFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bb_" .. i .. ".png")
                    end
                    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
                    cc.AnimationCache:getInstance():addAnimation(animation, "bb1")
                    local spriteFrames = {}
                    for i = 4, 11 do
                        spriteFrames[i - 3] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bb_" .. i .. ".png")
                    end
                    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.15)
                    cc.AnimationCache:getInstance():addAnimation(animation, "bb2")
                    local spriteFrames = {}
                    for i = 12, 14 do
                        spriteFrames[i - 11] = cc.SpriteFrameCache:getInstance():getSpriteFrame("bb_" .. i .. ".png")
                    end
                    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.05)
                    cc.AnimationCache:getInstance():addAnimation(animation, "bb3")
                end

                if param.toScene == "MainScene" or param.toScene == "EndlessMainScene" then
                    loadResource_1()
                else
                    loadResource_2()
                end

                local isLoading = false
                local currentRes = 0

                local function loaded(texture)
                    cc.SpriteFrameCache:getInstance():addSpriteFrames(resFiles[currentRes])        
                    isLoading = false
                end

                local function load(configFilePath)
                    isLoading = true
                    print "00000"
                    print(configFilePath)
                    cc.Director:getInstance():getTextureCache():addImageAsync(configFilePath,loaded)
                end

                local tranFinish = true
                --可以在此加载游戏资源   
                local function update()
                    if isLoading then
                        return
                    end
                    currentRes = currentRes + 1
                    if currentRes > #resImages then
                        if tranFinish == false then
                            return
                        end
                        self:unscheduleUpdate()
                        if param.toScene == "MainScene" then
                            LoadAni()
                            if param.isOverLimmit == false then
                                MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_START_LEVEL,param.id)
                            else
                                MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_START_LEVEL,(param.id + 100))
                            end
                            MyApp:enterMainScene(param)
                        elseif param.toScene == "LevelScene" then
                            MyApp:enterLevelScene(param)
                        elseif param.toScene == "IndexScene" then
                            MyApp:enterIndexScene(param)
                        elseif param.toScene == "WinScene" then
                            MyApp:enterWinScene(param)
                        elseif param.toScene == "EndlessMainScene" then
                            LoadAni()
                            MyApp:enterEndlessScene(param)
                        elseif param.toScene == "EndlessWinScene" then
                            MyApp:enterEndlessWinScene(param)
                        end
                        return
                    end
                    load(resImages[currentRes])
                end
                self:scheduleUpdateWithPriorityLua(update,0)
            
            end,1)
            
            
        end
    end)
end

return LoadingLayer