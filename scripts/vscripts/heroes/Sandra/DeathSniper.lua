--W技能 甩狙
DeathSniper = class({})

LinkLuaModifier("modifier_energy_stack", "heroes/Sandra/modifier_energy_stack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_passive", "heroes/Sandra/modifier_attack_passive.lua", LUA_MODIFIER_MOTION_NONE)

function DeathSniper:GetIntrinsicModifierName()
	return "modifier_attack_passive"
end

function DeathSniper:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	self.start_loc= caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	-- Ability specials
	local width = self:GetSpecialValueFor("width")
	local speed = self:GetSpecialValueFor("speed")
	--local radius = self:GetSpecialValueFor("damageradius")
	self.distance = self:GetSpecialValueFor("distance")
	local flytime = self.distance / speed
	self.baozhachufa = true

	--加层数
	local stack_modifier = caster:AddNewModifier(caster, self, "modifier_energy_stack", {})
	local old_stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
	local new_stack = old_stack + 1
	if new_stack >= 5 then
		new_stack = 5
	end
	caster:SetModifierStackCount("modifier_energy_stack", caster, new_stack)
	if new_stack == 5 then
		stack_modifier:ForceRefresh()
	end

	--投射物
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	local info = {
				EffectName = "particles/units/heroes/hero_mars/mars_spear_2.vpcf",
				StartPosition = "attach_hitloc",
				Ability = self,
				vSpawnOrigin = self:GetCaster():GetOrigin(), 
				fStartRadius = width,
				fEndRadius = width,
				vVelocity = vDirection * speed,
				fDistance = self.distance,
				Source = self:GetCaster(),
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
		self.projID = ProjectileManager:CreateLinearProjectile( info )

	--后撤
	local backstep_loc = target_point
	knockback_properties = {
			 center_x 			= backstep_loc.x,
			 center_y 			= backstep_loc.y,
			 center_z 			= backstep_loc.z,
			 duration 			= 0.3,
			 knockback_duration = 1,
			 knockback_distance = 600,
			 knockback_height 	= 0,
			 should_stun = 0,
			 effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf",
			 attach_type = PATTACH_ABSORIGIN_FOLLOW
				}
			local knockback_modifier = caster:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)

end

function DeathSniper:OnProjectileHit(hTarget, vLocation )
	local damage = self:GetCaster():GetAgility() * self:GetSpecialValueFor("multiple")
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damagetable = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		ApplyDamage( damagetable )
	end
	return false
end



function DeathSniper:OnProjectileThink(vlocation)
		local caster = self:GetCaster()
		local damage = self:GetCaster():GetAgility() * self:GetSpecialValueFor("multiple")*2
		local liudan = caster:FindAbilityByName("lava_cannon")
		local target_point = self:GetCursorPosition()

		if liudan.pos ~= nil then
			local Baozha_distance = (liudan.pos - vlocation):Length2D()
			if Baozha_distance < 150 then
				if self.baozhachufa then
					--地狱火特效
					--[[local particle_main_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(particle_main_fx, 0, liudan.pos)
			ParticleManager:SetParticleControl(particle_main_fx, 1, Vector(500, 0, 0))
			ParticleManager:ReleaseParticleIndex(particle_main_fx)]]--
					--导弹特效
					--[[local calldown_second_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(calldown_second_particle, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(calldown_second_particle, 1, target_point)
			ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(500, 500, 500))
			ParticleManager:ReleaseParticleIndex(calldown_second_particle)]]--
					--亚巴顿炸盾特效
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, target_point)
			ParticleManager:ReleaseParticleIndex(particle)

			--加层数
			local stack_modifier = caster:AddNewModifier(caster, self, "modifier_energy_stack", {})
			local old_stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
			local new_stack = old_stack + 1
			if new_stack >= 5 then
				new_stack = 5
			end
			caster:SetModifierStackCount("modifier_energy_stack", caster, new_stack)
			if new_stack == 5 then
			stack_modifier:ForceRefresh()
			end

					--爆炸伤害
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
				liudan.pos,
				nil,
				300,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false)

			for _,enemy in pairs(enemies) do
			ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

					--击退
			knockback_properties = {
			 center_x 			= liudan.pos.x,
			 center_y 			= liudan.pos.y,
			 center_z 			= liudan.pos.z,
			 duration 			= 0.5,
			 knockback_duration = 0.5,
			 knockback_distance = 300,
			 knockback_height 	= 50,
			 should_stun = 1,
				}
			local knockback_modifier = enemy:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)
			end
				self.baozhachufa = false
			end
		end
	end
end

