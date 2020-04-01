WarBanner_regen = WarBanner_regen or class({})

require 'helper/helperfunc'
LinkLuaModifier("modifier_aura_regen", "heroes/Lanquan/modifier_aura_regen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_regen", "heroes/Lanquan/modifier_aura_regen.lua", LUA_MODIFIER_MOTION_NONE)

function WarBanner_regen:OnOwnerSpawned()
	if self:GetAbilityIndex() == 0 then
		self:OnUpgrade()
	end
end

function WarBanner_regen:GetTexture()
	return "legion_commander_duel"
end

function WarBanner_regen:OnUpgrade()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:AddNewModifier(caster, self, "modifier_aura_regen", {})
	else
		caster:AddNewModifier(caster, self, "modifier_aura_regen", {})
	end
end

function WarBanner_regen:OnSpellStart()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	local particle_flag_cry = "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf"
	ParticleManager:CreateParticle(particle_flag_cry, PATTACH_ABSORIGIN, caster)
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:RemoveModifierByName("modifier_aura_regen")
	else
		caster:RemoveModifierByName("modifier_aura_regen")
	end--[[
	Timer(0.1, function()
		swap("WarBanner_damage", "WarBanner_regen", caster)
	end)]]
	swap("WarBanner_damage", "WarBanner_regen", caster)
end
