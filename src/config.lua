DEBUG_FPS = true

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = cc.ResolutionPolicy.FIXED_WIDTH

GAME_RES = {
    CURRENT = 1,
    HD = 1,
}
-- anim
GAME_ANIM = {
    INDEX_SCENE_ANI_FILE = "ui/indexScene/indexScene_ani.plist",
    INDEX_SCENE_ANI_IMG = "ui/indexScene/indexScene_ani.pvr.ccz",
    INDEX_SCENE_ANI_BAOQI_FILE = "ui/indexScene/baoqi.plist",
    INDEX_SCENE_ANI_BAOQI_IMG = "ui/indexScene/baoqi.pvr.ccz",
    }
--image
GAME_IMAGE = {
    UPDATE_IMAGE = "update/update_ui.pvr.ccz",
    UPDATE_FILE = "update/update_ui.plist",
    INDEX_SCENE_UI_FILE = "ui/indexScene/IndexSceneUI.plist",
    INDEX_SCENE_UI_IMG = "ui/indexScene/IndexSceneUI.pvr.ccz",
    INDEX_SCENE_UI_BG = "ui/uiBg/beijingtu.jpg",
    LEVEL_SCENE_UI_CUT_BG_1 = "ui/uiBg/levelMap1.jpg",
    LEVEL_SCENE_UI_CUT_BG_2 = "ui/uiBg/levelMap2.jpg",
    LEVEL_SCENE_UI_CUT_BG_3 = "ui/uiBg/levelMap3.jpg",
    LEVEL_SCENE_UI_FILE = "ui/levelScene/LevelScene.plist",
    LEVEL_SCENE_UI_IMG = "ui/levelScene/LevelScene.pvr.ccz",
    MAIN_SCENE_UI_FILE = "ui/mainScene/mainScene.plist",
    MAIN_SCENE_UI_IMG = "ui/mainScene/mainScene.pvr.ccz",
    WELCOME_SCENE_BG = "ui/welcomeScene/welcome_zdbwk.jpg",
    }
--ui
GAME_UI = {
    INDEX_LAYER_UI = "ui/Zjm.ExportJson",
    SHOW_LAYER_UI = "ui/Zsjm.ExportJson",
    RECHARGE_LAYER_UI = "ui/Czjm.ExportJson",
    TOP_LAYER_UI = "ui/Ty1.ExportJson",
    GIFT_LAYER_UI = "ui/libao.ExportJson",
    ACHIEVEMENTlAYER_LAYER_UI = "ui/Cjjm.ExportJson",
    ACHIEVEMENTlAYER_LAYER_LIST_UI = "ui/Cjjm_0.ExportJson",
    LEVEL_LAYER_UI = "ui/Mxjm.ExportJson",
    RESULT_LAYER_WIN = "ui/Sljm.ExportJson",
    RESULT_LAYER_LOSE = "ui/sbtc.ExportJson",
    PUB_DIALOG_RELIVE = "ui/Fhtc.ExportJson",
    LEVEL_INFO_BOSS = "ui/GqxzBoss.ExportJson",
    LEVEL_INFO_NORMAL = "ui/GqxzPt.ExportJson",
    MAIN_LAYER_UI = "ui/zdjm.ExportJson",
    SERVICE_LAYER_UI = "ui/Kftips.ExportJson",
    LICENCE_LAYER_UI = "ui/Jhm.ExportJson",
    PAUSE_LAYER_UI = "ui/Zttc.ExportJson",
    PUB_OPEN_HERO_UI = "ui/zjmTips.ExportJson",
    PUB_BATTLE_UI = "ui/Zlbz.ExportJson",
    PUB_DIALOG_UI = "ui/Tytips.ExportJson",
    WIN_ANI_UI = "ui/Zdsl.ExportJson",
    TOAST_UI = "ui/Tips.ExportJson",
    }
--KEY
GAME_KEY = {
    
    }
--FNT
GAME_FNT = {
    
    }
--粒子
GAME_PARTICLE = {
    OVER_LIMIT_PARTICLE = "ui/fireParticle.plist",
    OVER_LIMIT_PARTICLE_1 = "ui/fireParticle2.plist",
}

--7个星级的字体颜色
GAME_COLOR = {
    [1] = cc.c3b(0,255,48),
    [2] = cc.c3b(0,210,255),
    [3] = cc.c3b(246,0,255),
    [4] = cc.c3b(255,120,0),
    [5] = cc.c3b(255,204,0),
    [6] = cc.c3b(255,0,0),
    [7] = cc.c3b(204,255,0),
}

LANGUAGE_CHINESE = {
    IndexLayer = {
        [1] = "贝吉塔",
        [2] = "孙悟空",
        [3] = "悟吉塔",
        [4] = "人物已强化至最大等级",
        [5] = "继续强化需要进阶到%d星",
        [6] = "孙悟空已开启",
        [7] = "人物已进阶至最高星级",
        [8] = "未达最大等级",
        [9] = "强化成功",
        [10] = "进阶成功",
    },
    RechargeLayer = {
        [1] = "元",
        [2] = "金币",
        [3] = "购买成功",
    },
    AchievementLayer = {
        [1] = "%d星通关第%d关卡",
        [2] = "累计消灭%d个敌人",
        [3] = "累计强化%d次",
        [4] = "累计进阶%d次",
        [5] = "成就已全部完成！",
        [6] = "奖励%d金币",
        [7] = "未达领取条件",
        [8] = "未达领取条件",
        [9] = "未完成",
    },
    ShowLayer = {
        [1] = "            是赛亚人的王子，拥有最高贵的血统。为了光复赛亚人的荣光企图毁灭地球，与宿命之敌孙悟空相遇。性格孤傲倔强宁死不屈，在与悟空的战斗中虽一次次失败但始终百战不挠紧随其后，最终成为可以变身超级赛亚人四的强者！",
        [2] = "            最强单体战斗赛亚人，从小在地球长大自称地球人，以守护地球为己任。虽然体内拥有赛亚人的破坏因子但性格善良、毫无心机、喜好武术，在战斗中成长，打破赛亚人极限，龙珠系列超级赛亚人引导者！",
        [3] = "            是由孙悟空和贝吉塔使用融合术诞生的超级战士，七龙珠系列最强战斗赛亚人。性格嚣张、蔑视一切，战力爆表横扫宇宙！绝招：竖中指-破坏力骇人听闻！（看过悟吉塔出场的观众朋友都知道，悟吉塔出场就竖了几次中指虐一星龙跟虐菜一样）",
        [4] = "%d星",
        [5] = "等级:",
        [6] = "星",
    },
    GiftLayer = {
        [1] = "领取成功",
    },
    LicenceLayer = {
        [1] = "请输入您的激活码",
        [2] = "激活码不存在",
        [3] = "礼包已领取",
        [4] = "激活码输入框为空",
    },
    MainLayerUI = {
        [1] = "购买成功",
    },
    LevelLayer = {
        [1] = "开启条件：战斗力15000",
        [2] = "战斗力：%d",
    },
    LevelInfoLayer = {
        [1] = "每日挑战%d/%d",
        [2] = "敌方战力",
        [3] = "当前关卡，今日挑战次数已用完",
    },
    PubDialog = {
        [1] = "开启条件:通关第11关",--  提前开启:30000金币
        [2] = "您的金币不足50000",
        [3] = "立即获得星空核弹x10",
        [4] = "您的金币不足50000",
        [5] = "立即获得超级护盾x10",
        [6] = "金币不足，是否购买",
        [7] = "您的金币不足",
        [8] = "赠送    ",
        [9] = "购买成功",
        [10] = "提前开启:         30000金币",
        [11] = "提前开启:         120000金币",
    },
    GUIDE = {
        [1] = "尊敬的赛亚人战士:\n宇宙最恐怖的邪恶龙分身已经开始攻占地球，请您展现强大的力量将其打败。",
        [2] = "使用超级能量罩可以保\n护你10秒钟内不受伤害",
        [3] = "使用元气弹不仅可以消灭\n敌人还可以消除怪物子弹",
        [4] = "强化可以提升人物等级\n并且快速提升战斗力哦",
        [5] = "人物进阶不仅可以快速提升\n战斗力还会改变人物形态哦"
    }
}

GAME_SOUND = {
    --按钮点击音效
    TOUCH_EFFECT = "media/ui_btn.mp3",
    --界面背景音乐
    MENU_BG = "media/login.mp3",
    --游戏背景音乐0
    GAME_BG_0 = "media/gamebg0.mp3",
    --游戏背景音乐1
    GAME_BG_1 = "media/gamebg1.mp3",
    --游戏BOSS背景音乐1
    GAME_BOSS_BG = "media/gameboss0.mp3",
    --捡到金币的音效
    GET_DIAMOND_EFFECT = "media/shuijing.mp3",
    --核弹爆炸
    BOOM_EFFECT = "media/boom.mp3",
    --暴走
    POWERFULL_EFFECT = "media/powerfull.mp3",
    --升级
    LEVEL_UP_EFFECT = "media/sound_eff_impact_heal.mp3",
    --飞机飞走
    FLYAWAY_EFFECT = "media/flyaway.mp3",
    --捡到道具
    REWARD_EFFECT = "media/Sound_0015.mp3",
    --解锁关卡
    LEVEL_UNLOCK_EFFECT = "media/p_unlock.mp3",
    --护盾消失
    SHEILD_LOSE_EFFECT = "media/sheildlose.mp3",
    --321计时
    TTO_EFFECT = "media/321.mp3",
    --强化
    CONSOLIDATE_EFFECT = "media/consolidate.mp3",
    --进阶
    UPGRADE_EFFECT = "media/upgrade.mp3",
    --警告
    WARNING_EFFECT = "media/warning.mp3",
    --小怪爆炸
    LIGHTBOOM_EFFECT = "media/bomb_lightning.mp3",
}

--友盟自定义事件
UMENG_EVENT_ID = {
    --进入关卡
    EVENT_START_LEVEL = "EVENT_START_LEVEL",
    --失败关卡
    EVENT_FAIL_LEVEL = "EVENT_FAIL_LEVEL",
    --成功关卡
    EVENT_FINISH_LEVEL = "EVENT_FINISH_LEVEL",
--    --超级大礼包
--    EVENT_GIFT_SMS = "event_gift_sms",
--    --进阶2星
--    EVENT_UPGRADE2STAR_SMS = "event_upgrade_2star_sms",
--    --进阶3星
--    EVENT_UPGRADE3STAR_SMS = "event_upgrade_3star_sms",
--    --进阶4星
--    EVENT_UPGRADE4STAR_SMS = "event_upgrade_4star_sms",
--    --进阶6星
--    EVENT_UPGRADE6STAR_SMS = "event_upgrade_6star_sms",
--    --进阶7星
--    EVENT_UPGRADE7STAR_SMS = "event_upgrade_7star_sms",
--    --2万金币
--    EVENT_COIN2W_SMS = "event_coin_2w_sms",
--    --5万金币
--    EVENT_COIN5W_SMS = "event_coin_5w_sms",
--    --10万金币
--    EVENT_COIN10W_SMS = "event_coin_10w_sms",
--    --20万金币
--    EVENT_COIN20W_SMS = "event_coin_20w_sms",
--    --30万金币
--    EVENT_COIN30W_SMS = "event_coin_30w_sms",
--    --复活
--    EVENT_REVIVE_SMS = "event_revive_sms",
--    --10个元气弹
--    EVENT_BOOM_SMS = "event_boom_sms",
--    --10个能量罩
--    EVENT_PROTECT_SMS = "event_protect_sms",
--    --开启悟空
--    EVENT_WUKONG_SMS = "event_wukong_sms"
    
    --开始统计
    EVENT_STEP = "event_step_%d",
    --强化1-28级
    EVENT_CON_LEVEL = "event_con_%d_level",
    --进阶
    EVENT_UPGRADE_STAR = "event_up_%d_star",
    --购买天赐
    EVENT_TIANCI = "event_tianci",
    --购买战神祝福
    EVENT_ZHANSHENG = "event_zhansheng",
    --购买不屈
    EVENT_BUQU = "event_buqu",
    --购买蓄势
    EVENT_XUSHI = "event_xushi",
    --购买核弹
    EVENT_HEDAN = "event_hedan",
    --点击成就
    EVENT_CHENGJIU = "event_cehngjiu",
    --点击排行榜
    EVENT_PAIHANGBANG = "event_paihangbang", 
    --抽奖
    EVENT_CHOUJIANG = "event_choujiang",
    --激活龙珠
    EVENT_LONGZHU = "event_longzhu_%d",
    --进入极限模式
    EVENT_JIXIAN = "event_jixian",
    --进入无尽模式
    EVENT_WUJIN = "event_wujin"
}

IS_GUIDING = false


