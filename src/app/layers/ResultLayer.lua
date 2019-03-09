local ResultLayer = class("ResultLayer")

-- hp血量  id关卡 gold星钻 killEnemy杀敌数 isOverLimmit是否极限关卡 heroId传给关卡
function ResultLayer:newWinLayer(param)
    local layer = cc.Layer:create()
    
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.WIN_ANI_UI)
    layer:addChild(ui)
    
    --1胜利  2victory
    local img = {
        [1] = ui:getChildByName("Image_17"):getChildByName("Image_19"),
        [2] = ui:getChildByName("Image_17"):getChildByName("Image_18"),
        [3] = ui:getChildByName("Image_17")
    }
    
    local pY = img[1]:getPositionY()
    img[1]:setVisible(false)
    img[3]:setColor(cc.c3b(255,0,0))
    
    local panel = ui:getChildByName("Image_17")
    local sheng = cc.Sprite:createWithSpriteFrameName("zdjmSlwz2.png")
    local li = cc.Sprite:createWithSpriteFrameName("zdjmSlwz1.png")
    sheng:setPosition(-100,pY + 100)
    li:setPosition(display.width + 100,pY + 100)
    panel:addChild(sheng)
    panel:addChild(li)
    
    sheng:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.MoveTo:create(1,cc.p(display.cx - 80,pY)),
        cc.RotateBy:create(1,360)
        ),
        cc.ScaleTo:create(0.5,1.5),
        cc.ScaleTo:create(0.5,1)
    ))
    li:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(1,cc.p(display.cx + 80,pY)),
            cc.RotateBy:create(1,360)
        ),
        cc.ScaleTo:create(0.5,1.5),
        cc.ScaleTo:create(0.5,1)
    ))
    
    local function enterWinScene()
        param.toScene = "WinScene"
        MyApp:enterLoadingScene(param)
    end
    
    performWithDelay(layer,enterWinScene,2)
    
    if param.isOverLimmit == false then
        MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_FINISH_LEVEL,param.id)
    else
        MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_FINISH_LEVEL,(param.id+100))
    end
    
    return layer
end

function ResultLayer:newLoseLayer(param)
    local GiftLayer = require("app.layers.GiftLayer")

    local layer = cc.Layer:create()
    
    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.RESULT_LAYER_LOSE)
    layer:addChild(ui)

    --1提升战力  2返回关卡  3礼包
    local btn = {
        [1] = ui:getChildByName("Image_17"):getChildByName("Button_22"),
        [2] = ui:getChildByName("Image_17"):getChildByName("Button_26"),
        [3] = ui:getChildByName("Image_17"):getChildByName("Button_63"),
    }
    --1失败  2failed
    local img = {
        [1] = ui:getChildByName("Image_17"):getChildByName("Image_19"),
        [2] = ui:getChildByName("Image_17"):getChildByName("Image_18"),
    }
    
    for i = 1,2 do
        img[i]:setScale(3)
        img[i]:setPositionY(img[i]:getPositionY() + 200)
        img[i]:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseBounceOut:create(cc.ScaleTo:create(2,1)),
                cc.EaseBounceOut:create(cc.MoveBy:create(2,cc.p(0,-200)))
            ),
            cc.Blink:create(2,4)
        ))
    end

    for i = 1,3 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    param.toScene = "IndexScene"
                    MyApp:enterLoadingScene(param)
                elseif i == 2 then
                    param.toScene = "LevelScene"
                    MyApp:enterLoadingScene(param)
                elseif i == 3 then
                    layer:addChild(GiftLayer.new(param))
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
    
    if param.isOverLimmit == false then
        MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_FAIL_LEVEL,param.id)
    else
        MyApp:umengLevelEvent(UMENG_EVENT_ID.EVENT_FAIL_LEVEL,(param.id+100))
    end
    
    performWithDelay(layer, function ()
        layer:addChild(GiftLayer.new(param))
        print "fuck fuck fuck"
    end, 0.5)
    return layer
end

return ResultLayer