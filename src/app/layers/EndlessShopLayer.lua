local EndlessShopLayer = class("EndlessShopLayer",function()
    return cc.Layer:create()
end)

function EndlessShopLayer:ctor(param)
    local Toast = require("app.layers.Toast")
    local dataUi = require("tables.dataUi")
    local PubDialog = require("app.layers.PubDialog")

    local ui = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phbdj.ExportJson")
    self:addChild(ui)
    --1关闭  2进攻
    local btn = {
        [1] = ui:getChildByName("Image_18"):getChildByName("Button_16"),
        [2] = ui:getChildByName("Image_18"):getChildByName("Button_26_0"),
    }
    
    local img = {
        [1] = btn[2]:getChildByName("Image_27"),
        [2] = btn[2]:getChildByName("Image_87"),
        [3] = btn[2]:getChildByName("Image_87_0"),
    }
    
    local list = ui:getChildByName("Image_18"):getChildByName("ListView_53")
    
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

    local function addItem()
        local item = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/Phbdj_0.ExportJson")
        list:pushBackCustomItem(item)
        --1-5 从上至下的物品
        local prop = {
            [1] = item:getChildByName("Image_29"),
            [2] = item:getChildByName("Image_29_0"),
            [3] = item:getChildByName("Image_29_1"),
            [4] = item:getChildByName("Image_29_2"),
            [5] = item:getChildByName("Image_29_3"),
        }
        
        local btn = {}
        local lbl = {}
        
        for i = 1,5 do
            btn[i] = prop[i]:getChildByName("Button_57_0")
            lbl[i] = {}
            --描述1  描述2  金币数
            lbl[i][1] = prop[i]:getChildByName("Label_53")
            lbl[i][2] = prop[i]:getChildByName("Label_53_0")
            lbl[i][3] = btn[i]:getChildByName("Label_63")
        end
        
        --道具信息展示
        local price = {10000,10000,4000,3000,3000}
        local function showInfo()
            local dataUser = require("tables.dataUser")
            local endlessShop = dataUser.getEndlessShop()

            lbl[1][1]:setString("获得分数加成50%")
            if endlessShop[1] == 1 then
                lbl[1][2]:setVisible(true)
                lbl[1][2]:setString("已获得分数加成")
            else
                lbl[1][2]:setVisible(false)
            end
            lbl[1][3]:setString(price[1])

            lbl[2][1]:setString("攻击力提升30%")
            if endlessShop[2] == 1 then
                lbl[2][2]:setVisible(true)
                lbl[2][2]:setString("已获得攻击加成")
            else
                lbl[2][2]:setVisible(false)
            end
            lbl[2][3]:setString(price[2])

            lbl[3][1]:setString("消灭敌人并清除屏幕子弹")
            lbl[3][2]:setString("当前拥有核弹X"..dataUser.getBoom())
            lbl[3][3]:setString(price[3])
        end
        showInfo()
        
        local function freshUI()
            local dataUser = require("tables.dataUser")
            local endlessShop = dataUser.getEndlessShop()
            lbl[4][1]:setString("死后冲击8波怪物(可叠加5")
            lbl[4][2]:setString("次)当前死后冲击"..(endlessShop[4] * 8).."波怪")
            lbl[4][3]:setString(price[4])

            lbl[5][1]:setString("出场冲击8波怪物(可叠加5")
            lbl[5][2]:setString("次)当前出场冲击"..(endlessShop[5] * 8).."波怪")
            lbl[5][3]:setString(price[5])
        end
        freshUI()  
        
        for i = 1,5 do
            local function onBtn(sender,type)
                if type == ccui.TouchEventType.ended then
                    AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                    
                    local dataUser = require("tables.dataUser")
                    local endlessShop = dataUser.getEndlessShop()
                    
                    local param = {}
                    param.dialogId = 3
                    param.handler = function()
                        local dataUser = require("tables.dataUser")
                        local t = dataUi.getRecharge(5)
                        local rechargeGold = t.gold + t.giftGold
                        dataUser.increaseGold(rechargeGold)
                        dataUser.flushJson()
                        Toast:show("充值成功")
                        self:getParent():getChildByName("TopLayer"):fresh()
                    end
                    
                    if i == 1 or i == 2 then
                        if endlessShop[i] == 0 then
                            if dataUser.getGold() >= price[i] then
                                dataUser.increaseGold(-price[i])
                                endlessShop[i] = 1
                                Toast:show("购买成功")
                                if i == 1 then
                                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_TIANCI)
                                    print("友盟天赐")
                                elseif i == 2 then
                                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_ZHANSHENG)
                                    print("友盟战神祝福")
                                end
                            else
                                self:addChild(PubDialog:newGoldDialog(param))
                            end
                        elseif endlessShop[i] == 1 then
                            Toast:show("已购买")
                        end
                    elseif i == 3 then
                        if dataUser.getGold() >= price[i] then
                            dataUser.increaseGold(-price[i])
                            dataUser.increaseBoom(1)
                            Toast:show("购买成功")
                            
                            MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_HEDAN)
                            print("友盟核弹")
                        else
                            self:addChild(PubDialog:newGoldDialog(param))
                        end
                    elseif i == 4 or i == 5 then
                        if endlessShop[i] < 5 then
                            if dataUser.getGold() >= price[i] then
                                dataUser.increaseGold(-price[i])
                                endlessShop[i] = endlessShop[i] + 1
                                Toast:show("购买成功")
                                
                                if i == 4 then
                                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_BUQU)
                                    print("友盟不屈")
                                elseif i == 5 then
                                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_XUSHI)
                                    print("友盟蓄势")
                                end
                            else
                                self:addChild(PubDialog:newGoldDialog(param))
                            end                        
                        else
                            Toast:show("购买次数已达上限")
                        end
                    end
                    dataUser.flushJson()
                    freshUI()
                    showInfo()
                    self:getParent():getChildByName("TopLayer"):fresh()
                end
            end
            btn[i]:addTouchEventListener(onBtn)
        end
    end
    addItem()
    
    for i = 1,2 do
        local function onBtn(sender,type)
            if type == ccui.TouchEventType.ended then
                AudioUtil.playEffect(GAME_SOUND.TOUCH_EFFECT,false)
                if i == 1 then
                    self:removeFromParent(true)
                elseif i == 2 then
                    btnUp()
                    MyApp:enterLoadingScene(param)
                end
            elseif type == ccui.TouchEventType.began then
                if i == 2 then
                    btnDown()
                    
                    print("无尽模式")
                    MyApp:umemngEvent(UMENG_EVENT_ID.EVENT_WUJIN)
                end  
            end
        end
        btn[i]:addTouchEventListener(onBtn)
    end
end

return EndlessShopLayer