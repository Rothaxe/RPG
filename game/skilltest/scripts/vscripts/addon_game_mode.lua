--创建类
if CAddonTemplateGameMode == nil then
	_G.CAddonTemplateGameMode = class({})
end

--链接脚本
require('shuaguai')

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
    GameRules:SetHeroSelectionTime( 5 )
    GameRules:SetPreGameTime(0)

    --开始监听
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonTemplateGameMode,"OnGameRulesStateChange"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(CAddonTemplateGameMode,"OnEntityKilled"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonTemplateGameMode, "OnNPCSpawned"), self)
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
            --开始刷怪
            StartShuaGuai()
         end
end

function CAddonTemplateGameMode:OnNPCSpawned( keys )
	print("OnNPCSpawned")
	local hero = EntIndexToHScript(keys.entindex)
	--if hero:GetName() == "npc_dota_hero_lina" then
	if hero:GetName() == "npc_dota_hero_lina" then
		local ability = hero:FindAbilityByName("Effect_Lauren")
		if ability ~= nil then
			print(ability)
			ability:SetLevel(4)
			hero:AddNewModifier(hero, ability, "Modifier_Effect", {})
			hero:AddNewModifier(hero, ability, "Modifier_Effect_Counter", {})
		end
	end
end

--单位死亡事件
function CAddonTemplateGameMode:OnEntityKilled( keys )
	local killed = EntIndexToHScript(keys.entindex_killed)
    --获取标签
	local label = killed:GetContext("name")
	--击杀A单位X秒后，在随机位置重新刷A单位
	if label == "Axe" then
	Timer(5,function()
		createunit("Axe") 
		end)
	end
	
	if label == "redwolf" then
	Timer(5,function()
		createunit("redwolf")
	end)
	end

end
