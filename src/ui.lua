--region ui.lua
--Author : shiyi_000
--Date   : 2014/6/30
--此文件由[BabeLua]插件自动生成

ui = {}

ui.DEFAULT_TTF_FONT      = "Arial"
ui.DEFAULT_TTF_FONT_SIZE = 24

ui.TEXT_ALIGN_LEFT    = kCCTextAlignmentLeft
ui.TEXT_ALIGN_CENTER  = kCCTextAlignmentCenter
ui.TEXT_ALIGN_RIGHT   = kCCTextAlignmentRight
ui.TEXT_VALIGN_TOP    = kCCVerticalTextAlignmentTop
ui.TEXT_VALIGN_CENTER = kCCVerticalTextAlignmentCenter
ui.TEXT_VALIGN_BOTTOM = kCCVerticalTextAlignmentBottom

--创建菜单
function ui.newMenu(items)
    local menu
    menu = cc.Menu:create()
    for k, item in pairs(items) do
        if not tolua.isnull(item) then
            menu:addChild(item, 0, item:getTag())
        end
    end
    menu:setPosition(0, 0)
    return menu
end
--创建菜单项
function ui.newImageMenuItem(params)
    local imageNormal   = params.image
    local imageSelected = params.imageSelected
    local imageDisabled = params.imageDisabled
    local listener      = params.listener
    local tag           = params.tag
    local x             = params.x
    local y             = params.y
    local sound         = params.sound

    if type(imageNormal) == "string" then
        imageNormal = display.newSprite(imageNormal)
    end
    if type(imageSelected) == "string" then
        imageSelected = display.newSprite(imageSelected)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newSprite(imageDisabled)
    end
    local item = cc.MenuItemSprite:create(imageNormal, imageSelected, imageDisabled)
    if item then
        if type(listener) == "function" then
            item:registerScriptTapHandler(function(tag)
                if sound then audio.playSound(sound) end
                listener(tag)
            end)
        end
        if x and y then item:setPosition(x, y) end
        if tag then item:setTag(tag) end
    end
    return item
end
--创建文本
function ui.newBMFontLabel(params)
    assert(type(params) == "table",
           "[framework.ui] newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or ui.TEXT_ALIGN_CENTER
    local x, y      = params.x, params.y
    local color = params.color
    assert(font ~= nil, "ui.newBMFontLabel() - not set font")
    local label = cc.Label:createWithBMFont(font, text)
    label:setAlignment(textAlign)
    --local label = CCLabelBMFont:create(text, font, kCCLabelAutomaticWidth, textAlign)
    if not label then return end
    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end
    if textAlign == ui.TEXT_ALIGN_LEFT then
        --label:setAlignment(display.LEFT_CENTER)
        label:setAnchorPoint(0, 0.5)
    elseif textAlign == ui.TEXT_ALIGN_RIGHT then
        --label:setAlignment(display.RIGHT_CENTER)
       label:setAnchorPoint(1, 0.5)
    else
        --label:setAlignment(display.CENTER)
        label:setAnchorPoint(0.5, 0.5)
    end
    if color then 
        label:setColor(color)
    end
    return label
end

--endregion
