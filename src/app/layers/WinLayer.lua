local WinLayer = class("WinLayer",function()
    return cc.Layer:create()
end)

-- hp血量  id关卡 gold星钻 killEnemy杀敌数 isOverLimmit是否极限关卡 heroId传给关卡
function WinLayer:ctor(param)
    local dataUser = require("tables.dataUser")
    local GuideLayer = require("app.layers.GuideLayer")
    
    local bg = cc.Sprite:create(GAME_IMAGE.INDEX_SCENE_UI_BG,cc.rect(0,0,640,1140))
    bg:setPosition(display.cx,display.cy)
    self:addChild(bg)
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.RESULT_LAYER_WIN)
    self:addChild(ui)

    IS_GUIDING = false

    --1继续
    local btn = {
        [1] = ui:getChildByName("Button_22"),
    }
    --1金币  2杀敌
    local lbl = {
        [1] = ui:getChildByName("Image_28"):getChildByName("Image_29"):getChildByName("Label_37"),
        [2] = ui:getChildByName("Image_28"):getChildByName("Image_29_0"):getChildByName("Label_39"),
    }
    --1通关成功  2反光  3背光  4五星背景 5-6按钮的状态
    local img = {
        [1] = ui:getChildByName("Image_28"):getChildByName("Image_40"),
        [2] = ui:getChildByName("Image_17"):getChildByName("Image_21"),
        [3] = ui:getChildByName("Image_27"),
        [4] = ui:getChildByName("Image_17"):getChildByName("Image_18"),
        [5] = btn[1]:getChildByName("Image_26"),
        [6] = btn[1]:getChildByName("Image_23"),
        [7] = ui:getChildByName("Image_17"):getChildByName("Image_20"),
    }
    --从左至右5个星星
    local star = {
        [1] = ui:getChildByName("Image_28"):getChildByName("Image_49"),
        [2] = ui:getChildByName("Image_28"):getChildByName("Image_50"),
        [3] = ui:getChildByName("Image_28"):getChildByName("Image_39"),
        [4] = ui:getChildByName("Image_28"):getChildByName("Image_51"),
        [5] = ui:getChildByName("Image_28"):getChildByName("Image_52"),
    }
    --从左至右5个星星的光晕
    local starEffect = {
        [1] = ui:getChildByName("Image_28"):getChildByName("Image_38_1_2"),
        [2] = ui:getChildByName("Image_28"):getChildByName("Image_38_0_1"),
        [3] = ui:getChildByName("Image_28"):getChildByName("Image_38"),
        [4] = ui:getChildByName("Image_28"):getChildByName("Image_38_0"),
        [5] = ui:getChildByName("Image_28"):getChildByName("Image_38_1"),
    }
    
    --根据血量评星
    local function showStar(hp)
        if hp <= 25 then
            return 1
        elseif hp > 25 and hp <= 50 then
            return 2
        elseif hp > 50 and hp <= 75 then
            return 3
        elseif hp > 75 and hp < 100 then
            return 4
        elseif hp == 100 then
            return 5
        end
    end
    
    lbl[1]:setString(param.gold)
    
    lbl[2]:setString(param.killEnemy)
    img[6]:setVisible(false)

    img[1]:setScale(0)
    img[1]:runAction(cc.Spawn:create(
        cc.ScaleTo:create(1,1),
        cc.RotateBy:create(1,720)
    ))

    img[2]:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.CallFunc:create(
            function()
                img[2]:setPositionX(120) img[2]:setOpacity(0) 
            end),
        cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveBy:create(0.2,cc.p(30,0))),
        cc.MoveBy:create(2,cc.p(350,0)),
        cc.Spawn:create(cc.FadeOut:create(0.2),cc.MoveBy:create(0.2,cc.p(30,0))),
        cc.DelayTime:create(2)
    )))

    img[3]:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(2,360)
    ))
    
    if showStar(param.hp) == 5 then
        img[7]:runAction(cc.Sequence:create(
            cc.ScaleTo:create(1,1.5),
            cc.ScaleTo:create(1,1),
            cc.CallFunc:create(function()
                if showStar(param.hp) == 5 then
                    lbl[1]:setString(param.gold * 2)
                else
                    lbl[1]:setString(param.gold)
                end
            end)
        ))
    end
    
    for i = 1,5 do
        star[i]:setScale(0)
    --    starEffect[i]:setScale(0)
    end
    for i = 1,showStar(param.hp) do
        star[i]:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5 * i),
            cc.EaseBackInOut:create(cc.ScaleTo:create(0.5,1))
        ))
--        starEffect[i]:setScale(0)
--        starEffect[i]:runAction(cc.Sequence:create(
--            cc.DelayTime:create(0.5 * i),
--            cc.EaseBackInOut:create(cc.ScaleTo:create(0.5,1))
--        ))
    end 

    --结算星星
    local level
    if param.isOverLimmit == false then
        level = dataUser.getLevel()
    else
        level = dataUser.getLimitLevel()
    end
    if level[param.id].star < showStar(param.hp) then
        level[param.id].star = showStar(param.hp)
    end
    if level[param.id + 1] == nil then
        level[param.id + 1] = {}
        level[param.id + 1].star = 0
        level[param.id + 1].dayLimit = 0
        dataUser.changeFirstPass(true)
    end
    --结算次数
    level[param.id].dayLimit = level[param.id].dayLimit + 1
    --结算金币和杀敌
    if showStar(param.hp) == 5 then
        dataUser.increaseGold(param.gold * 2)
    else
        dataUser.increaseGold(param.gold)
    end
    local task3 = dataUser.getTask().task3
    task3.killEnemy = task3.killEnemy + param.killEnemy
    dataUser.flushJson()

    for i = 1,1 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    if IS_GUIDING == true then
                        self:getParent():removeChildByTag(GuideLayer.TAG)
                        IS_GUIDING = false
                    end
                
                    img[5]:setVisible(true)
                    MyApp:enterLevelScene({heroId = param.heroId,isOverLimmit = param.isOverLimmit})
                end
            elseif type == ccui.TouchEventType.began then
                if i == 1 then
                    img[5]:setVisible(false)
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
    
    local function showGuide()

        local function guide_1()
            local size = btn[1]:getContentSize()
            local pos = btn[1]:getWorldPosition()

            local guide = GuideLayer.new()
            guide:show(self:getParent(), {mode = 2, pos =pos, size = size})    
        end

        local GUIDE_1 = cc.UserDefault:getInstance():getBoolForKey("GUIDE_4", false)
        if GUIDE_1 == false then
            IS_GUIDING = true
            guide_1()
            return
        end
    end

    performWithDelay(self, showGuide,0.02)
    
end

return WinLayer