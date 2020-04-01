BloodCry = class({})

LinkLuaModifier("Modifier_Group_Bleed", "heroes/Lauren/Modifier_Group_Bleed.lua", LUA_MODIFIER_MOTION_NONE)

function BloodCry: OnSpellStart()
	local radius = self:GetSpecialValueFor("radius")
	local caster = self:GetCaster()
	local position = caster:GetOrigin()
		--搜敌
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
			self:OnHit(enemy, damage, stun_time)
	end
		--特效
	local blast_pfx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, position)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)
		EmitSoundOnLocationWithCaster( position, "Ability.LightStrikeArray", caster )
end

function BloodCry: OnHit(target, damage, stun_time)
	local caster = self:GetCaster()
	local ability = self
	local stun_time = self:GetSpecialValueFor("stun_time")
		--群体晕
	local stun_modifier = target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_time})
		--计算抗性
		if stun_modifier then
			stun_modifier:SetDuration(stun_time * (1 - target:GetStatusResistance()), true)
		end
		--群体血魔大
	local Modifier_Group_Bleed = target:AddNewModifier(caster, self, "Modifier_Group_Bleed", {duration = stun_time*5})
end