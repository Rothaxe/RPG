WarBanner_reduce = WarBanner_reduce or class({})

require 'helper/helperfunc'
LinkLuaModifier("modifier_aura_red", "heroes/Lanquan/modifier_aura_red.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_red", "heroes/Lanquan/modifier_aura_red.lua", LUA_MODIFIER_MOTION_NONE)

function WarBanner_reduce:OnOwnerSpawned()
	if self:GetAbilityIndex() == 0 then
		self:OnUpgrade()
	end
end

function WarBanner_reduce:OnUpgrade()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:AddNewModifier(caster, self, "modifier_aura_red", {})
	else
		caster:AddNewModifier(caster, self, "modifier_aura_red", {})
	end
end

function WarBanner_reduce:OnSpellStart()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	local particle_flag_cry = "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf"
	ParticleManager:CreateParticle(particle_flag_cry, PATTACH_ABSORIGIN, caster)
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:RemoveModifierByName("modifier_aura_red")
	else
		caster:RemoveModifierByName("modifier_aura_red")
	end
	swap("WarBanner_regen", "WarBanner_reduce", caster)
end