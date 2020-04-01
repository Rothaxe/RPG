BellucciTallent = class({})
--层数BUFF：贝鲁奇的天赋

LinkLuaModifier("modifier_energy_stack", "heroes/Sandra/modifier_energy_stack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fast_buff", "heroes/Modifier/modifier_fast_buff.lua", LUA_MODIFIER_MOTION_NONE)


function BellucciTallent:GetIntrinsicModifierName()
	return "modifier_energy_stack"
end


function BellucciTallent:OnSpellStart()
	local caster = self:GetCaster()
	local stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
	local duration = self:GetSpecialValueFor("timeperstack")*stack
	local hpregen = self:GetSpecialValueFor("hpregenpct")*stack
	local speed_modifier = caster:AddNewModifier(caster, self, "modifier_fast_buff", {duration = duration})
	caster:SetModifierStackCount("modifier_energy_stack", caster, 0)
	local cast_pfx = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/gold_storm_spirit_ti8_overload_flash.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_foot", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(cast_pfx)
	if stack >= 5 then
		local laser = caster:FindAbilityByName("UltimateLaser")
		local EXlaser = caster:FindAbilityByName("ExUltimateLaser")
		if laser ~= nil then
		laser:StartCooldown(EXlaser:GetCooldownTimeRemaining())
		caster:SwapAbilities("UltimateLaser", "ExUltimateLaser", true, false)
		end
	end
end