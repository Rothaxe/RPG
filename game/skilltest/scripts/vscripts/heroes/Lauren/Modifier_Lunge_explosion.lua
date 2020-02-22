Modifier_Lunge_explosion = Modifier_Lunge_explosion or class({})

function Modifier_Lunge_explosion:IsPurgable() 
	return false 
end

function Modifier_Lunge_explosion:IsDebuff() 
	return false 
end

function Modifier_Lunge_explosion:IsHidden()
	return true
end


function Modifier_Lunge_explosion:OnCreated()
	if IsServer() then
		local caster = self:GetParent()
		local position = caster:GetAbsOrigin()
		local radius = self:GetAbility():GetSpecialValueFor("explosion_radius")
		local damage = self:GetAbility():GetSpecialValueFor("explosion_damage")
		local stun_duration = self:GetAbility():GetSpecialValueFor("explosion_stun_time")

		local cast_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeam())
		ParticleManager:SetParticleControl(cast_pfx, 0, position)
		ParticleManager:SetParticleControl(cast_pfx, 1, Vector(radius * 2, 0, 0))
		ParticleManager:ReleaseParticleIndex(cast_pfx)

		local blast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, position)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)
		EmitSoundOnLocationWithCaster( position, "Ability.LightStrikeArray", caster )

		-- 破坏树
		--GridNav:DestroyTreesAroundPoint(position, radius, false)

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in ipairs(enemies) do
			self:OnHit(enemy, damage, stun_duration)
		end
	end
end

function Modifier_Lunge_explosion:OnHit( target, damage, stun_duration )
	local caster = self:GetCaster()
	ApplyDamage({attacker = caster, victim = target, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- 查下敌人是否死亡，防bug
	if target:IsAlive() then
		local stun_modifier = target:AddNewModifier(caster, self, "Modifier_stunned", {duration = stun_duration})
		--计算抗性
		if stun_modifier then
			stun_modifier:SetDuration(stun_duration * (1 - target:GetStatusResistance()), true)
		end
	end
end





