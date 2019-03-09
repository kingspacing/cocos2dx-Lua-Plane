local GuideLayer = class("GuideLayer", function() 
    return cc.Layer:create()
end)

GuideLayer.Z_ORDER = 10
GuideLayer.TAG = 9889


function GuideLayer:show(root, data)
    if data.mode == 1 then
        local darkBG = cc.LayerColor:create(cc.c4b(0,0,0,110))
        self:addChild(darkBG)
    
        local uiRoot = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/guide/guideUI.ExportJson")
        self:addChild(uiRoot)
        
        local panel = uiRoot:getChildByName("Panel_7")
        local size = panel:getContentSize()
        panel:setContentSize(cc.size(size.width, data.height))
        
        local msgText = uiRoot:getChildByName("Panel_7"):getChildByName("Label_10")
        msgText:setString(data.msg)
        if data.alignment then
            msgText:setTextHorizontalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        end
        
        
        local mianfeiText = uiRoot:getChildByName("Panel_7"):getChildByName("Label_6")
        mianfeiText:setVisible(false)
        if data.isFree then
            mianfeiText:setVisible(true)
        end
        
        uiRoot:addTouchEventListener(function(sender, event) 
            if event == ccui.TouchEventType.ended then
                data.callback(self, 1)
            end
        end)
    else
        local darkBG = cc.LayerColor:create(cc.c4b(0,0,0,110))
        local touchRect = cc.rect(0,0,0,0) 
        
        local stencil = ccui.Scale9Sprite:createWithSpriteFrameName("guidekuang.png", cc.rect(1,1,2,2))
        stencil:setPosition(data.pos)
        stencil:setPreferredSize(data.size)
        
        local clippingNode = cc.ClippingNode:create(stencil)
        clippingNode:setInverted(true)
        clippingNode:addChild(darkBG)
        self:addChild(clippingNode)
        
        local arrow = cc.Sprite:createWithSpriteFrameName("yindao2.png")
        local action = cc.Sequence:create({
            cc.MoveBy:create(0.4, cc.p(0, 40)),
            cc.MoveBy:create(0.4, cc.p(0, -40))
        })
        arrow:runAction(cc.RepeatForever:create(action))
        arrow:setAnchorPoint(cc.p(0.5,0))
        arrow:setPosition(data.pos.x, data.pos.y + data.size.height / 2 + 10)
        clippingNode:addChild(arrow)
        
        local kuang = ccui.Scale9Sprite:createWithSpriteFrameName("yindao1.png", cc.rect(25,25,40,27))
        kuang:setPosition(data.pos)
        kuang:setPreferredSize(cc.size(data.size.width + 50,data.size.height + 50))
        clippingNode:addChild(kuang)
        
        local function onTouchBegan(touch, event)
            local pos = touch:getLocation()
            if cc.rectContainsPoint(stencil:getBoundingBox(), pos) then
                return false
            end
            return true
        end

        --注册触摸事件
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
    end
    
    root:addChild(self, GuideLayer.Z_ORDER, GuideLayer.TAG )
end


return GuideLayer



