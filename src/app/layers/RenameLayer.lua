local RenameLayer = class("RenameLayer",function()
    return cc.Layer:create()
end)

function RenameLayer:ctor(name,handler)
    local Toast = require("app.layers.Toast")

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.LICENCE_LAYER_UI)
    self:addChild(ui)

    --1关闭  2确定
    local btn = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Button_16"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
    }

    --1输入  2联网   3请输入激活码
    local text = {
        [1] = ui:getChildByName("Image_18"):getChildByName("TextField_17"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Label_16_0_0"),
        [3] = ui:getChildByName("Image_18"):getChildByName("Label_16_0"),
    }

    local img = {
        [1] = btn[2]:getChildByName("Image_27"),
        [2] = btn[2]:getChildByName("Image_87"),
        [3] = btn[2]:getChildByName("Image_87_0"),
    }

    local function btnUp()
        img[1]:setVisible(true)
        img[2]:setVisible(true)
        img[3]:setVisible(false)
    end
    btnUp()
    local function btnDown()
        img[1]:setVisible(false)
        img[2]:setVisible(false)
        img[3]:setVisible(true)
    end

    local panel = ui:getChildByName("Image_18")

    text[1]:setVisible(false)
    text[3]:setString("请输入游戏名称")

    local dataUser = require "tables.dataUser"
    require("json")

    local function showToast(message, t)
        performWithDelay(self,function()
            Toast:show(message)
        end,t*2)
    end

    -- 激活码输入框
    local textFieldInput = ccui.EditBox:create(cc.size(140, 40),ccui.Scale9Sprite:create("gqxzPic2.png"),ccui.Scale9Sprite:create("gqxzPic2.png"),ccui.Scale9Sprite:create("gqxzPic2.png"))
    textFieldInput:setPosition(panel:getContentSize().width/2, 165)
    textFieldInput:setPosition(panel:getContentSize().width/2 - 40, 165)
    --    textFieldInput:setInputMode(inputMode)
    textFieldInput:setPlaceHolder("请输入玩家名称")
    textFieldInput:setMaxLength(8)
    textFieldInput:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    ui:getChildByName("Image_18"):addChild(textFieldInput, 2)

    for i = 1,2 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                if i == 1 then
                    handler(false)
                    self:removeFromParent(true)
                elseif i == 2 then
                    btn[2]:setEnabled(false)
                    local function handle(parameters)
                        btn[2]:setEnabled(true)
                        if parameters then
                            print(parameters.is_succeed)
                            if parameters.is_succeed then
                                
                                -- 修改成功
                                Toast:show("修改成功")
                                self:removeFromParent(true)
                            else
                                -- 修改失败
                                Toast:show("服务端已经有与你相同的名字")
                            end
                        else
                            -- 网络异常
                            Toast:show("网络异常")
                        end
                    end
                    Chart.userRename(textFieldInput:getText(), handle)
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end 
end

return RenameLayer