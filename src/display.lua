require "config"
display = {}
cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, CONFIG_SCREEN_AUTOSCALE)  
cc.Director:getInstance():setDisplayStats(DEBUG_FPS)
--位置大小
local winSize = cc.Director:getInstance():getVisibleSize()
display.size               = {width = winSize.width, height = winSize.height}
display.width              = display.size.width
display.height             = display.size.height
display.cx                 = display.width / 2
display.cy                 = display.height / 2
display.left               = 0
display.right              = display.width
display.top                = display.height
display.bottom             = 0

display.AUTO_SIZE      = 0
display.FIXED_SIZE     = 1
display.LEFT_TO_RIGHT  = 0
display.RIGHT_TO_LEFT  = 1
display.TOP_TO_BOTTOM  = 2
display.BOTTOM_TO_TOP  = 3

display.CENTER        = 1
display.LEFT_TOP      = 2; display.TOP_LEFT      = 2
display.CENTER_TOP    = 3; display.TOP_CENTER    = 3
display.RIGHT_TOP     = 4; display.TOP_RIGHT     = 4
display.CENTER_LEFT   = 5; display.LEFT_CENTER   = 5
display.CENTER_RIGHT  = 6; display.RIGHT_CENTER  = 6
display.BOTTOM_LEFT   = 7; display.LEFT_BOTTOM   = 7
display.BOTTOM_RIGHT  = 8; display.RIGHT_BOTTOM  = 8
display.BOTTOM_CENTER = 9; display.CENTER_BOTTOM = 9

--颜色
display.COLOR_WHITE = cc.c3b(255, 255, 255)
display.COLOR_BLACK = cc.c3b(0, 0, 0)
display.COLOR_RED   = cc.c3b(255, 0, 0)
display.COLOR_GREEN = cc.c3b(0, 255, 0)
display.COLOR_BLUE  = cc.c3b(0, 0, 255)
--创建场景
function display.newScene()
    return cc.Scene:create()
end
--创建图层
function display.newLayer()
    return cc.Layer:create()
end
--创建有颜色图层
function display.newColorLayer(color, w, h)
    if not w then w = display.width end
    if not h then h = display.height end 
    return cc.LayerColor:create(color, w, h)
end
--创建节点
function display.newNode()
    return cc.Node:create()
end
--创建精灵
function display.newSprite(filename, x, y)
    local t = type(filename)
    if t == "userdata" then t = tolua.type(filename) end
    local sprite = cc.Sprite:create()
    if not filename then
        sprite = cc.Sprite:create()
    elseif t == "string" then
        if string.byte(filename) == 35 then -- first char is #
            local frame = display.newSpriteFrame(string.sub(filename, 2))
            if frame then
                sprite =  cc.Sprite:createWithSpriteFrame(frame)
            end
        else
            sprite =  cc.Sprite:create(filename)
        end
    elseif t == "CCSpriteFrame" then
        sprite = cc.Sprite:createWithSpriteFrame(filename)
    else
        echoError("display.newSprite() - invalid filename value type")
        sprite = cc.Sprite:create()
    end

    if sprite then
        if x and y then sprite:setPosition(x, y) end
    else
        echoError("display.newSprite() - create sprite failure, filename %s", tostring(filename))
        sprite = cc.Sprite:create()
    end
    return sprite
end
--创建9宫格精灵
function display.newScale9Sprite(filename, x, y, size)
    local t = type(filename)
    if t ~= "string" then
        echoError("display.newScale9Sprite() - invalid filename type")
        return
    end

    local sprite
    if string.byte(filename) == 35 then -- first char is #
        local frame = display.newSpriteFrame(string.sub(filename, 2))
        if frame then
            sprite = cc.Scale9Sprite:createWithSpriteFrame(frame)
        end
    else
        sprite = cc.Scale9Sprite:create(filename)
    end
    if sprite then
        if x and y then sprite:setPosition(x, y) end
        if size then sprite:setContentSize(size) end
    else
        echoError("display.newScale9Sprite() - create sprite failure, filename %s", tostring(filename))
    end
    return sprite
end
--创建精灵批处理
function display.newBatchNode(image, capacity)
    return cc.SpriteBatchNode:create(image, capacity or 100)
end
--创建精灵帧
function display.newSpriteFrame(frameName)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
    if not frame then
        echoError("display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
    end
    return frame
end
--加载精灵帧文件
function display.addSpriteFramesWithFile(plistFilename, image)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistFilename, image)
end
--清脆精灵帧文件
function display.removeSpriteFramesWithFile(plistFilename)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistFilename)
end

function display.grayNode(node)
    if node then
        local program = cc.GLProgram:create("ui/gray.vsh","ui/gray.fsh")
        program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
        program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
        program:link()
        program:updateUniforms()
        node:setGLProgram(program)
    end
end

