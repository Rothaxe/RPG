--创建类
if CAddonTemplateGameMode == nil then
	_G.CAddonTemplateGameMode = class({})
end

if Filter == nil then
   Filter = class{}
end
--链接脚本
require('shuaguai')
require('util/playerutil')
require('triggers/basictrigger')

--预载入
--function Precache( context )
		--PrecacheResource( "model_folder", "models", context )
		--PrecacheResource( "particle_folder", "particles", context )
--end

--激活游戏
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
	a = 12345
	print(a)
end

--初始化
function CAddonTemplateGameMode:InitGameMode()
	--游戏设定
    GameRules:SetStartingGold( 20000 )
    GameRules:SetHeroSelectionTime( 0 )
    GameRules:SetPreGameTime(0)
    GameRules:SetSameHeroSelectionEnabled( true ) --允许选择重复英雄，因为默认都要选择同一个马甲单位，以解决选英雄阶段掉线的问题
    GameRules:SetUseBaseGoldBountyOnHeroes(false)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetHideKillMessageHeaders(true)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0)
    GameRules:SetUseUniversalShopMode( true ) --为真时，所有物品当处于任意商店范围内时都能购买到，包括神秘商店商店物品

    local mode = GameRules:GetGameModeEntity()
    mode:SetCustomGameForceHero("npc_dota_hero_wisp")

    mode:SetMaximumAttackSpeed( 600 ) -- 设置单位的最大攻击速度
    mode:SetMinimumAttackSpeed( 20 ) -- 设置单位的最小攻击速度
    mode:SetUseCustomHeroLevels ( true )-- 是否允许使用自定义英雄等级（不使用，则默认只有25级）
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )  -- 定义英雄经验值表(table)，通过这个表来确定总共有多少级
    mode:SetFogOfWarDisabled(false) -- 是否关闭战争迷雾（对两方都有效）
    mode:SetUnseenFogOfWarEnabled(true)--启用/禁用战争迷雾（上边为false才有用）
    mode:SetBuybackEnabled( false )-- 是否允许买活
    mode:SetSelectionGoldPenaltyEnabled( false ) --英雄选择界面超时未选择英雄的金币减少惩罚
    mode:SetLoseGoldOnDeath(false)--死亡金钱损失
    mode:SetRecommendedItemsDisabled( true )
    mode:SetStashPurchasingDisabled ( true )-- 是否关闭/开启储藏处购买功能。如果该功能被关闭，英雄必须在商店范围内购买物品
    mode:SetHUDVisible(12, false)
    --mode:SetHUDVisible(2, false)
    --mode:SetHUDVisible(9, false)
    mode:SetItemAddedToInventoryFilter(Dynamic_Wrap(Filter,"ItemAddedToInventoryFilter"), Filter)
    GameRules.DropTable = LoadKeyValues("scripts/kv/item_drops.kv")
    GameRules.SpawnTable = LoadKeyValues("scripts/kv/spawn.kv")
    --开始监听
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonTemplateGameMode,"OnGameRulesStateChange"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(CAddonTemplateGameMode,"OnEntityKilled"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonTemplateGameMode, "OnNPCSpawned"), self)
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CAddonTemplateGameMode, "RemoveWearables"), self)
	

    --注册监听UI事件
    CustomGameEventManager:RegisterListener( "SelectNewGame", SelectNewGame )
    CustomGameEventManager:RegisterListener( "myui_open", OnMyUIOpen )
    CustomGameEventManager:RegisterListener('choose_lauren', ChooseLauren)
    CustomGameEventManager:RegisterListener('choose_arven', ChooseArven)
    CustomGameEventManager:RegisterListener('choose_sandra', ChooseSandra)
    CustomGameEventManager:RegisterListener( "back_to_initial_page", BackToInitialPage)
    CustomUI:DynamicHud_Create(-1, "InitialPage", "file://{resources}/layout/custom_game/Initial_Page.xml",nil)


	Timer(3, function() 

                local req = CreateHTTPRequestScriptVM("POST", "https://b438.playfabapi.com/Client/LoginWithCustomID")

                req:SetHTTPRequestHeaderValue("Content-Type", "application/json")

                local encoded = '{"CustomId": "'..tostring(PlayerResource:GetSteamID(0))..'","CreateAccount": true,"TitleId": "3376F"}'

                req:SetHTTPRequestRawPostBody("application/json",encoded)

             req:Send(function(res)

                print("[STATS] Received", res.Body)

                        local resbody = json.decode(res.Body)

                        local data = resbody["data"]

                local session_ticket=data["SessionTicket"]

                local playfab_id=data['PlayFabId']

                print(session_ticket)

            end)

        end)
end

MAX_LEVEL = 60                               
-- 每一级的升级所需经验，这个经验要包括之前所有等级的经验，是一个经验总量，而不是当前等级升级还需要的经验。
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
    local xp = 0;
    if i > 1 then
        xp = 499 + math.pow(i-1,2) + XP_PER_LEVEL_TABLE[i - 1] 
    end
    XP_PER_LEVEL_TABLE[i] = xp
end


--计时器
function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end

--判断游戏正式开始，同时开始刷怪
function CAddonTemplateGameMode:OnGameRulesStateChange( keys )
         local state = GameRules:State_Get()

         if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
            --创建选人界面
            CustomUI:DynamicHud_Create(-1,"InitialPage","file://{resources}/layout/custom_game/Initial_Page.xml",nil)
            --开始刷怪
            StartShuaGuai()

         end
end


LinkLuaModifier("modifier_random_scale", "modifiers/modifier_random_scale.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bianyi", "modifiers/modifier_bianyi.lua", LUA_MODIFIER_MOTION_NONE)

function CAddonTemplateGameMode:OnNPCSpawned( keys )
    local unit = EntIndexToHScript(keys.entindex)
	if unit:IsRealHero() then
 		--[[local ability = hero:FindAbilityByName("Effect_Lauren")
		if ability ~= nil then
			print(ability)
			ability:SetLevel(4)
			hero:AddNewModifier(hero, ability, "Modifier_Effect", {})
			hero:AddNewModifier(hero, ability, "Modifier_Effect_Counter", {})
		end]]--
        --移除天赋
        for i = 0, 23 do
        local ability = unit:GetAbilityByIndex(i)
            if ability then
                local name = ability:GetAbilityName()
                if string.find(name, "special_bonus") then
                print("removed ability", name)
                unit:RemoveAbility(name)
                end
            end
        end
    end

    if unit:GetName() == "npc_dota_creature" and unit:GetTeam() == 3 then
        --unit:AddNewModifier(unit, nil, "modifier_random_scale", {})
        if RollPercentage(2) then 
        unit:AddNewModifier(unit, nil, "modifier_bianyi", {})
        end
    end
end


-----------------------------------UI事件------------------------------------------------------------------------------
function SelectNewGame( index,keys )
        CustomUI:DynamicHud_Destroy(-1, "InitialPage")
        CustomUI:DynamicHud_Create(-1, "StartPage", "file://{resources}/layout/custom_game/Start_Page.xml",nil)
end

    --选择罗伦
function ChooseLauren( index,keys )
        --用罗伦替换默认马甲英雄LINA
        PlayerResource:ReplaceHeroWith(keys.PlayerID,"npc_dota_hero_axe", 0, 0)
        --选完人关闭界面
        CustomUI:DynamicHud_Destroy(-1, "StartPage")
end

    --选择亚纹
function ChooseArven( index,keys )
        --用亚纹替换默认马甲英雄LINA
        PlayerResource:ReplaceHeroWith(keys.PlayerID,"npc_dota_hero_pangolier", 0, 0)
        --选完人关闭界面
        CustomUI:DynamicHud_Destroy(-1, "StartPage")
end

    --选择珊德拉
function ChooseSandra( index,keys )
        --用珊德拉替换默认马甲英雄LINA
        PlayerResource:ReplaceHeroWith(keys.PlayerID,"npc_dota_hero_windrunner", 0, 0)
        --选完人关闭界面
        CustomUI:DynamicHud_Destroy(-1, "StartPage")
end

function BackToInitialPage( index,keys )
        CustomUI:DynamicHud_Destroy(-1, "StartPage")
        CustomUI:DynamicHud_Create(-1, "InitialPage", "file://{resources}/layout/custom_game/Initial_Page.xml",nil)
end

--function OpenInventory( index,keys )
        --CustomUI:DynamicHud_Create(-1, "open_inventory", "file://{resources}/layout/custom_game/inventory.xml",nil)
        --CustomUI:DynamicHud_Destroy(-1, "inventoryicon")
       -- CustomUI:DynamicHud_Create(-1, "inventoryiconclose", "file://{resources}/layout/custom_game/inventoryiconclose.xml",nil)
--end

--function CloseInventory( index,keys )
        --CustomUI:DynamicHud_Destroy(-1, "open_inventory")
        --CustomUI:DynamicHud_Destroy(-1, "inventoryiconclose")
        --CustomUI:DynamicHud_Create(-1,"inventoryicon","file://{resources}/layout/custom_game/inventoryicon.xml",nil)
--end
-------------------------------------------------------------------------------------------------------------------------

--单位死亡事件
function CAddonTemplateGameMode:OnEntityKilled( keys )
    local killed = EntIndexToHScript(keys.entindex_killed)
    --获取标签
    local label = killed:GetContext("name")
    --变异
    local bianyi = killed:GetContext("bianyi")
    local owner = killed:GetOwner()
    local name = owner:GetName()

    --击杀A单位X秒后，在随机位置重新刷A单位
    if label == "deer"  then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "BigDeer"  then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "SoulDeer"  then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "spider" then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "redwolf"  then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "bigwolf"  then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "HunterWiper" then
    Timer(5,function()
        RespawnGroupUnit(name)
    end)
    RollDrops(killed) --掉落
    end

    if label == "spiderboss" then
    Timer(20,function()
        OnStartTouch2()
    end)
    RollDrops(killed) --掉落
    end



    if bianyi == "bianyied" then
    BigDrops(killed)
    end

    --英雄复活时间设置
        if killed:IsHero() then
        local respawnTime = CAddonTemplateGameMode:GetHeroRespawnTime(killed)
        killed:SetTimeUntilRespawn(respawnTime)
    end
end

function CAddonTemplateGameMode:GetHeroRespawnTime(hero)
    local respawnTime = (5 + (hero:GetLevel()/4))
    if(respawnTime > 30) then respawnTime = 30 end
    return respawnTime
end


function CAddonTemplateGameMode:RemoveWearables(keys)
local hero = EntIndexToHScript(keys.heroindex)
local children = hero:GetChildren()
        for k,child in pairs(children) do
           if child:GetClassname() == "dota_item_wearable" then
               child:RemoveSelf()
           end
        end
end

--掉落系统
function RollDrops(unit)
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
        for k,ItemTable in pairs(DropInfo) do
            local chance = ItemTable.Chance or 100
            local max_drops = ItemTable.Multiple or 1
            local item_name = ItemTable.Item
            for i=1,max_drops do -- 其他都是基本一样的，这里加个循环来多次掉落而已
                if RollPercentage(chance) then
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    local pos = unit:GetAbsOrigin()
                    local drop = CreateItemOnPositionSync( pos, item )
                    local pos_launch = pos+RandomVector(RandomFloat(0,0))
                    item:LaunchLoot(false, 500, 0.5, pos_launch) --(是否自动实用，高度，飞行时间，掉落位置)
                    item:GetContainer():SetModelScale(1)
                    item:GetContainer():SetForwardVector(RandomVector(400))
                    --local looteffect = ParticleManager:CreateParticle("particles/neutral_fx/neutral_item_drop.vpcf", PATTACH_WORLDORIGIN, item)
					--ParticleManager:SetParticleControl(looteffect, 0, item:GetAbsOrigin())
                end
            end
        end
    end
end

--大爆
function BigDrops(unit)
    local unitlvl = unit:GetLevel()
    for i = 1, RandomInt(unitlvl, unitlvl + 5) do
        local coin = CreateItem("item_TrueGold", nil, nil)
        coin:SetPurchaseTime(0)
        local pos = unit:GetAbsOrigin()
        local drop = CreateItemOnPositionSync( pos, coin ) 
        local pos_launch = pos+RandomVector(RandomFloat(0,0))
        coin:LaunchLoot(true, 500, 0.5, pos_launch + RandomVector(300))
    end
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN, unit)
        ParticleManager:ReleaseParticleIndex(particle)

end

--物品过滤器
function Filter:ItemAddedToInventoryFilter(filtertable)
	--DeepPrintTable(filtertable)
	return true
end


					--护甲模型models/items/dragon_knight/firedragon_shoulder/firedragon_shoulder.vmdl
					--武器模型models/heroes/phantom_assassin/weapon_fx.vmdl
					--宝箱models/props_gameplay/treasure_chest_gold.vmdl
					--凤凰蛋models/items/phoenix/ultimate/blazing_wing_blazing_egg/blazing_wing_blazing_egg.vmdl
					--莲花models/items/dark_willow/dark_willow_ti8_immortal_head/dark_willow_ti8_immortal_flower.vmdl
					--血石models/props_items/bloodstone.vmdl
					--A杖models/props_gameplay/aghanim_scepter.vmdl
					--戒指models/props_items/ring_health.vmdl
					--钱袋models/props_gameplay/gold_bag.vmdl

                    --分配信使
                    --[[local courier = CreateUnitByName("xinshi", (Entities:FindByName(nil, "xinshi")):GetAbsOrigin(), true, nil, unit, DOTA_TEAM_GOODGUYS)--信使
                    courier:SetOwner(unit);
                    courier:SetControllableByPlayer(unit:GetPlayerID(),true)]]--  --是否可以进行控制，如果不可被控制，则即便能选中，也不能移动、操作


