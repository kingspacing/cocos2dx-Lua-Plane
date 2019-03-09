local WarningLayer = class("WarningLayer",function()
    return cc.Layer:create()
end)

function WarningLayer:ctor()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(GAME_IMAGE.MAIN_SCENE_UI_FILE,GAME_IMAGE.MAIN_SCENE_UI_IMG)
    --不动层
    local function newBaseLayer()
        local layer = cc.Layer:create()
        
        local boss = cc.Sprite:createWithSpriteFrameName("warn_bosslaixi.png")
        local redLineUp = cc.Sprite:createWithSpriteFrameName("warn_tiao.png")
        local redLineDown = cc.Sprite:createWithSpriteFrameName("warn_tiao.png")
        local triangleLeft = cc.Sprite:createWithSpriteFrameName("warn_fuhao.png")
        local triangleRight = cc.Sprite:createWithSpriteFrameName("warn_fuhao.png")
        
        boss:setPosition(display.cx,display.cy)
        redLineUp:setPosition(display.cx,display.cy + 150)
        redLineDown:setPosition(display.cx,display.cy - 150)
        triangleLeft:setPosition(display.cx - 250,display.cy)
        triangleRight:setPosition(display.cx + 250,display.cy)
        
        local function action1(sp,maxSize)
            sp:setOpacity(0)
            sp:setScale(0.7)
            sp:runAction(cc.Sequence:create(
            cc.Spawn:create(cc.ScaleTo:create(0.5,maxSize),cc.FadeIn:create(0.5)),
            cc.ScaleTo:create(0.2,1),
            cc.FadeOut:create(0.3),
            cc.Spawn:create(cc.ScaleTo:create(0.5,maxSize),cc.FadeIn:create(0.5)),
            cc.ScaleTo:create(0.2,1),
            cc.FadeOut:create(0.3)
            ))
        end
        
        local function action2(sp)
            sp:runAction(cc.Sequence:create(
            cc.DelayTime:create(1.5),
            cc.FadeOut:create(0.5)
            ))
        end
        
        action1(boss,1.2)
        action1(triangleLeft,1.1)
        action1(triangleRight,1.1)
        action2(redLineUp)
        action2(redLineDown)
        
        layer:addChild(boss)
        layer:addChild(redLineUp)
        layer:addChild(redLineDown)
        layer:addChild(triangleLeft)
        layer:addChild(triangleRight)
        
        return layer
    end
    
    local function leftWarn()
        local layer = cc.Layer:create()
        
        local warning = {}
        for i = 1,5 do
            warning[i] = cc.Sprite:createWithSpriteFrameName("warn_yingwen.png")
            warning[i]:setPosition(display.width + (i-1) * 250,display.cy + 150)
            warning[i]:setAnchorPoint(0,0.5)
            layer:addChild(warning[i])
            
            warning[i]:runAction(cc.Sequence:create(
                cc.MoveBy:create(1.5,cc.p(-750,0)),
                cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(-250,0)),
                                cc.FadeOut:create(0.5))
            ))
        end
        
        return layer
    end
    
    local function rightWarn()
        local layer = cc.Layer:create()
        
        local warning = {}
        for i = 1,5 do
            warning[i] = cc.Sprite:createWithSpriteFrameName("warn_yingwen.png")
            warning[i]:setPosition(- (i-1) * 250,display.cy - 150)
            warning[i]:setAnchorPoint(1,0.5)
            layer:addChild(warning[i])

            warning[i]:runAction(cc.Sequence:create(
                cc.MoveBy:create(1.5,cc.p(750,0)),
                cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(250,0)),
                                cc.FadeOut:create(0.5))
            ))
        end

        return layer
    end
    
    local function leftArrow()
        local layer = cc.Layer:create()
        
        local arrow = {}
        for i = 1,10 do
            arrow[i] = cc.Sprite:createWithSpriteFrameName("warn_jiantou.png")
            arrow[i]:setFlippedX(false)
            arrow[i]:setOpacity(0)
            arrow[i]:setPosition(display.cx,display.cy)

            arrow[i]:runAction(cc.Sequence:create(
            cc.DelayTime:create((i-1) * 0.2),
            cc.Spawn:create(
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(2,cc.p(-1600,0)))
            ))

            layer:addChild(arrow[i])
        end
        
        local function ended()
            for i = 1,10 do
                arrow[i]:runAction(cc.FadeOut:create(0.5))
            end
        end
        
        performWithDelay(layer,ended,1.5)

        return layer
    end
    
    local function rightArrow()
        local layer = cc.Layer:create()
        
        local arrow = {}
        for i = 1,10 do
            arrow[i] = cc.Sprite:createWithSpriteFrameName("warn_jiantou.png")
            arrow[i]:setFlippedX(true)
            arrow[i]:setOpacity(0)
            arrow[i]:setPosition(display.cx,display.cy)
            
            arrow[i]:runAction(cc.Sequence:create(
            cc.DelayTime:create((i-1) * 0.2),
            cc.Spawn:create(
                    cc.FadeIn:create(0.2),
                    cc.MoveBy:create(2,cc.p(1600,0)))
            ))
            
            layer:addChild(arrow[i])
        end
        
        local function ended()
            for i = 1,10 do
                arrow[i]:runAction(cc.FadeOut:create(0.5))
            end
        end
        
        performWithDelay(layer,ended,1.5)

        return layer
    end
    
    local layer = {}
    layer[1] = newBaseLayer()
    layer[2] = leftWarn()
    layer[3] = rightWarn()
    layer[4] = leftArrow()
    layer[5] = rightArrow()
    
    for i = 5,1,-1 do
        self:addChild(layer[i])
    end
end

return WarningLayer