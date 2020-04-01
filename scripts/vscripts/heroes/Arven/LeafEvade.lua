LinkLuaModifier( "modifier_evasion_aura" , "heroes/Arven/modifier_evasion_aura.lua" , LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fast_buff" , "heroes/Modifier/modifier_fast_buff.lua" , LUA_MODIFIER_MOTION_NONE )
--require ('heroes/Lauren/Modifier_Parry')

LeafEvade = class({})

function LeafEvade:GetIntrinsicModifierName()
	return "modifier_evasion_aura"
end

function LeafEvade:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local friends = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		1000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
	for _,friend in pairs(friends) do 
	friend:AddNewModifier(caster, self, "modifier_fast_buff", {duration = duration})
	end
end