Modifier_Lunge_Slashes = Modifier_Lunge_Slashes or class({})
require ('util/Timer')

function Modifier_Lunge_Slashes:OnCreated()
	self.particle = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf"
	self.hit_particle = "particles/generic_gameplay/generic_hit_blood.vpcf"
	self.slashing_sound = "Hero_Pangolier.Swashbuckle"
	self.hit_sound= "Hero_Pangolier.Swashbuckle.Damage"
	self.slash_particle = {}
	
	self.range = self:GetAbility():GetSpecialValueFor("range")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.start_radius = self:GetAbility():GetSpecialValueFor("start_radius")
	--self.end_radius = self:GetAbility():GetSpecialValueFor("end_radius")
	self.strikes = self:GetAbility():GetSpecialValueFor("strikes")
	self.attack_interval = self:GetAbility():GetSpecialValueFor("attack_interval")

	if IsServer() then
		self.executed_strikes = 0
		self.isBuffed = false

		--等一帧
		Timers:CreateTimer(FrameTime(), function()
			self.direction = nil -- needed for the particle
			if self.target then
				self.direction = (self.target:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
				self.fixed_target = self:GetCaster():GetAbsOrigin() + self.direction * self.range -- 固定方向
			else 
				self.direction = self:GetCaster():GetForwardVector():Normalized()
				self.fixed_target = self:GetCaster():GetAbsOrigin() + self.direction * self.range
			end

			self:StartIntervalThink(self.attack_interval)
		end)
	end
end

function Modifier_Lunge_Slashes:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}

	return declfuncs
end

function Modifier_Lunge_Slashes:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1_END
end

function Modifier_Lunge_Slashes:OnIntervalThink()
	if IsServer() then
		if self.executed_strikes == self.strikes then
			self:Destroy()
			return nil
		end

		self.slash_particle[self.executed_strikes] = ParticleManager:CreateParticle(self.particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 0, self:GetCaster():GetAbsOrigin()) --origin of particle
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 1, self.direction * self.range) --direction and range of the subparticles


		EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), self.slashing_sound, self:GetCaster())

		--戳
		local buff = self:GetParent():FindModifierByName("Modifier_Lunge_buff")
		local range_increased = self:GetAbility():GetSpecialValueFor("range_increased")
		--print(self.fixed_target)
		if buff ~= nil then
			if self.isBuffed ~= true then
				self.fixed_target = self.fixed_target + self.direction * range_increased
				--print(self.fixed_target)
				self.isBuffed = true
			end
		end
		local enemies = FindUnitsInLine(
			self:GetCaster():GetTeamNumber(),
			self:GetCaster():GetAbsOrigin(),
			self.fixed_target,
			nil,
			self.start_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		)

		for _,enemy in pairs(enemies) do
			EmitSoundOn(self.hit_sound, enemy)

			if not enemy:IsAttackImmune() then

				local blood_particle = ParticleManager:CreateParticle(self.hit_particle, PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(blood_particle, 0, enemy:GetAbsOrigin()) --origin of particle
				ParticleManager:SetParticleControl(blood_particle, 2, self.direction * 500) --direction and speed of the blood spills


				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "Modifier_Lunge_damage", {})
				self:GetCaster():PerformAttack(enemy, true, true, true, true, false, false, true)
				self:GetCaster():RemoveModifierByName("Modifier_Lunge_damage")
			end
		end

		self.executed_strikes = self.executed_strikes + 1
	end
end

function Modifier_Lunge_Slashes:OnRemoved()
	if IsServer() then
		--移除特效
		for k,v in pairs(self.slash_particle) do
			ParticleManager:DestroyParticle(v, false)
			ParticleManager:ReleaseParticleIndex(v)
		end
	end
end

function Modifier_Lunge_Slashes:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end