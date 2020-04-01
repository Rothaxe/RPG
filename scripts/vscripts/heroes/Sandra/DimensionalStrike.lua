DimensionalStrike = class({})
require ('util/helperfunc')
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)
function DimensionalStrike:OnSpellStart()
	local caster = self:GetCaster()
	local start_loc = caster:GetAbsOrigin()
	local target = self:GetCursorTarget()
	local target_loc = self:GetCursorPosition()
	local feidan_radius = self:GetSpecialValueFor("feidan_radius")
	local feidan_damage = self:GetSpecialValueFor("feidan_damage_multiple")*caster:GetIntellect()
	self.feidan = true
	self.feidanshanghai = true

		--立绘
	local calldown_second_particle = ParticleManager:CreateParticle("particles/msg_capturepoints_neutral2.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(calldown_second_particle, 1, start_loc)

	Timer(0,function()
		if self.feidan == false then
			self.feidan = true
			return
		end
	
		--金色飞弹
	local calldown_second_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown__2second.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(calldown_second_particle, 0, start_loc)
	ParticleManager:SetParticleControl(calldown_second_particle, 1, target_loc)
	ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(300, 300, 300))
	ParticleManager:ReleaseParticleIndex(calldown_second_particle)
	
		--周身特效
	local surround_particle = ParticleManager:CreateParticle("particles/units/unit_greevil/loot_greevil_tgt_end_rings.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(surround_particle, 1, start_loc)
	ParticleManager:ReleaseParticleIndex(surround_particle)
	
			--飞弹伤害
		Timer(2,function()
		if self.feidanshanghai == false then
		self.feidanshanghai = true
		return
		end

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		target_loc,
		nil,
		feidan_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
		

		for _,enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, ability = self, damage = feidan_damage, damage_type = self:GetAbilityDamageType()})
		end
		end)

	return 0.2
	end)


		--靶心连线
	local laser_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/_3tinker_laser_e.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)	
	ParticleManager:SetParticleControl(laser_pfx, 1, Vector(target_loc.x,target_loc.y,start_loc.z))
	ParticleManager:SetParticleControl(laser_pfx, 9, Vector(start_loc.x,start_loc.y,start_loc.z))

		--红色靶心
	local target_particle = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_target_2.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(target_particle,0, target_loc)
	ParticleManager:ReleaseParticleIndex(target_particle)
end

function DimensionalStrike:OnChannelFinish(bInterrupted)
	if self.feidan ~= nil then
	self.feidan = false
end
	if self.feidanshanghai ~= nil then
	self.feidanshanghai = false
end
	if bInterrupted then
	return
	else
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()


		local info = {
				EffectName = "particles/units/heroes/hero_mars/mars_spear_2.vpcf",
				StartPosition = "attach_attack1",
				Ability = self,
				vSpawnOrigin = self:GetCaster():GetOrigin(), 
				fStartRadius = self:GetSpecialValueFor("width"),
				fEndRadius = self:GetSpecialValueFor("width"),
				vVelocity = vDirection * self:GetSpecialValueFor("speed"),
				fDistance = self:GetSpecialValueFor("distance"),
				Source = self:GetCaster(),
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
			ProjectileManager:CreateLinearProjectile( info )

		--后撤步
		local backstep_loc = self:GetCursorPosition()
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
			local knockback_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_custom_knockback", knockback_properties)
	end
end

function DimensionalStrike:OnProjectileHit(hTarget, vLocation)
		local caster = self:GetCaster()
		local damage = caster:GetAgility() * self:GetSpecialValueFor("multiple")
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damagetable = {
			victim = hTarget,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		ApplyDamage( damagetable )

		--敌人转身
		hTarget:FaceTowards(caster:GetAbsOrigin() * (-1))
		hTarget:SetForwardVector((hTarget:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized())
	end
end