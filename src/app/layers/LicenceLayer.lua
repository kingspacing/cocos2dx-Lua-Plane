local LicenceLayer = class("LicenceLayer",function()
    return cc.Layer:create()
end)

-- 第一步 客户端向服务端发送一条string类型的licence
-- 第二步 客户端等待服务端的应答，客户端希望接收以下数据结构。
-- 注意：服务端返回以Json格式的数据。若激活码有效，result返回1，无效返回-1，已激活返回0。当激活码有效时，reward就是存放奖品数组

-- 收回来的数据结构
local data = {
    reward = {
        [1] = {type = nil, id = nil, quantity = nil},
        [2] = {type = nil, id = nil, quantity = nil},
    -- ...
    },
    result = nil,
}

-- data数据结构
-- reward 数组
-- result 返回结果

-- 奖品数据结构
-- type 类型 1星钻 2道具 3材料
-- id 奖品id
-- quantity 奖品数量

function LicenceLayer:ctor()
    local Toast = require("app.layers.Toast")

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile(GAME_UI.LICENCE_LAYER_UI)
    self:addChild(ui)
    
    --1关闭  2确定
    local btn = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Button_16"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Button_26"),
    }
    
    local text = {
        [1] = ui:getChildByName("Image_18"):getChildByName("TextField_17")
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
    textFieldInput:setPlaceHolder(LANGUAGE_CHINESE.LicenceLayer[1])
    textFieldInput:setMaxLength(8)
    textFieldInput:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND )
    ui:getChildByName("Image_18"):addChild(textFieldInput, 2)
    
    for i = 1,2 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    self:removeFromParent(true)
                elseif i == 2 then
                    local str = textFieldInput:getText()
                    textFieldInput:setText("")
                    -- 激活码输入框不为空
                    if string.len(str) > 0 then
                        local lt = dataUser.getLicence()
                        local flag = 0
                        local rewardID
                        local A = string.sub(str, 2, 2)
                        local B = string.sub(str, 7, 7)
                        if string.len(str) ~= 8 then
                            flag = 0
                        -- 金币20000，元气弹*2，护盾*2
                        elseif (A == "a" and B == "z") then
                            if not lt["az"] then
                                flag = true
                                dataUser.increaseLicence("az")
                                rewardID = 1
                            else
                                flag = -1
                            end
                        -- 金币50000，元气弹*5，护盾*5
                        elseif (A == "b" and B == "y") then
                            if not lt["by"] then
                                flag = true
                                dataUser.increaseLicence("by")
                                rewardID = 2
                            else
                                flag = -1
                            end
                        -- 金币100000，元气弹*10，护盾*10
                        elseif (A == "c" and B == "x") then
                            if not lt["cx"] then
                                flag = true
                                dataUser.increaseLicence("cx")
                                rewardID = 3
                            else
                                flag = -1
                            end
--                        elseif (A == "d" and B == "w") then
--                            if not lt["dw"] then
--                                flag = true
--                                dataUser.increaseLicence("dw")
--                                rewardID = 4
--                            else
--                                flag = -1
--                            end
                        end
                        if flag == 0 then
                            Toast:show(LANGUAGE_CHINESE.LicenceLayer[2])
                        elseif flag == -1 then
                            Toast:show(LANGUAGE_CHINESE.LicenceLayer[3])
                        else
                            local dataUser = require("tables.dataUser")
                            local t = 0
                            local function showMsg(t, info)
                            	performWithDelay(self, function ()
                                    Toast:show(info, 1)
                            	end, t)
                            end
                            -- 金币20000，元气弹*2，护盾*2
                            if rewardID == 1 then
                                dataUser.increaseGold(20000)
                                showMsg(t, "恭喜你获得金币*20000")
                                t = t + 1
                                dataUser.increaseBoom(2)
                                showMsg(t, "恭喜你获得元气弹*2")
                                t = t + 1
                                dataUser.increaseShield(2)
                                showMsg(t, "恭喜你获得护盾*2")
                            -- 金币50000，元气弹*5，护盾*5
                            elseif rewardID == 2 then
                                dataUser.increaseGold(50000)
                                showMsg(t, "恭喜你获得金币*20000")
                                t = t + 1
                                dataUser.increaseBoom(5)
                                showMsg(t, "恭喜你获得元气弹*5")
                                t = t + 1
                                dataUser.increaseShield(5)
                                showMsg(t, "恭喜你获得护盾*5")
                            -- 金币100000，元气弹*10，护盾*10
                            elseif rewardID == 3 then
                                dataUser.increaseGold(100000)
                                showMsg(t, "恭喜你获得金币*100000")
                                t = t + 1
                                dataUser.increaseBoom(10)
                                showMsg(t, "恭喜你获得元气弹*10")
                                t = t + 1
                                dataUser.increaseShield(10)
                                showMsg(t, "恭喜你获得护盾*10")
                            end
                            dataUser.flushJson()
                            self:getParent():fresh()
                        end
                    else
                        Toast.show(LANGUAGE_CHINESE.LicenceLayer[4])
                    end
                    btnUp()
                end
            elseif type == ccui.TouchEventType.began then
                if i == 2 then
                    btnDown()
                end
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end 
end

return LicenceLayer