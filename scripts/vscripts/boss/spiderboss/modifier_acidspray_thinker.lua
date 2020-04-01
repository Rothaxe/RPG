modifier_acidspray_thinker = modifier_acidspray_thinker or class({})

function modifier_acidspray_thinker:OnCreated(keys)
	if IsServer() then
		self.caster = self:GetCaster()
		self.thinker = self:GetParent()
		self.ability = self:GetAbility()
		
		self.ability_target_team	= self.ability:GetAbilityTargetTeam()
		self.ability_target_type	= self.ability:GetAbilityTargetType()
		self.ability_target_flags	= self.ability:GetAbilityTargetFlags()
		self.ability_dmg_type = self.ability:GetAbilityDamageType()
		self.thinker_loc = self.thinker:GetAbsOrigin()

		self.thinker:EmitSound("Hero_Alchemist.AcidSpray")

		self.radius = self.ability:GetSpecialValueFor("radius")

		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_POINT_FOLLOW, self.thinker)
		ParticleManager:SetParticleControl(self.particle, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(self.particle, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(self.particle, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(self.particle, 16, (Vector(0, 0, 0)))

		self.damaged_enemies	= {}

		self:StartIntervalThink(0.2)
	end
end

function modifier_acidspray_thinker:OnIntervalThink()
	print(self.thinker_loc)
	local units = FindUnitsInRadius(self.thinker:GetTeamNumber(),
		self.thinker_loc,
		nil,
		self.radius,
		self.ability_target_team,
		self.ability_target_type,
		self.ability_target_flags,
		FIND_ANY_ORDER,
		false)

	for _,unit in pairs (units) do
		if not self.damaged_enemies[unit] then
		ApplyDamage({attacker = self.caster, victim = unit, ability = self.ability, damage = self.ability:GetSpecialValueFor("dot_damage"), damage_type = self.ability_dmg_type })
		self.damaged_enemies[unit] = true
		end
	end
end


function modifier_acidspray_thinker:OnDestroy(keys)
	if IsServer() then
		local thinker = self:GetParent()
		thinker:StopSound("Hero_Alchemist.AcidSpray")
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end
