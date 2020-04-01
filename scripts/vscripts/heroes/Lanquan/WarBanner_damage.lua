WarBanner_damage = WarBanner_damage or class({})

require 'helper/helperfunc'
LinkLuaModifier("modifier_aura_damage", "heroes/Lanquan/modifier_aura_damage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_damage", "heroes/Lanquan/modifier_aura_damage.lua", LUA_MODIFIER_MOTION_NONE)


function WarBanner_damage:GetTexture()
	return "legion_commander_duel"
end

function WarBanner_damage:OnOwnerSpawned()
	if self:GetAbilityIndex() == 0 then
		self:OnUpgrade()
	end
end
function WarBanner_damage:OnUpgrade()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:AddNewModifier(caster, self, "modifier_aura_damage", {})
	else
		caster:AddNewModifier(caster, self, "modifier_aura_damage", {})
	end
end

function WarBanner_damage:OnSpellStart()
	local caster = self:GetCaster()
	local flag_status = caster:FindModifierByName("flag_status")
	local particle_flag_cry = "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf"
	ParticleManager:CreateParticle(particle_flag_cry, PATTACH_ABSORIGIN, caster)
	if flag_status then 
		local flag = Entities:FindByModel(nil, flag_status.flag_model)
		flag:RemoveModifierByName("modifier_aura_damage")
	else
		caster:RemoveModifierByName("modifier_aura_damage")
	end
	swap("WarBanner_reduce", "WarBanner_damage", caster)
end