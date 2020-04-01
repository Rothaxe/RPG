--2020.02.12 所有bug已修复

HeavenlyExecution = HeavenlyExecution or class({})

function HeavenlyExecution:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local sound_cast = "Hero_Nevermore.RequiemOfSouls"
	local particle_caster_souls = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf"
	local particle_caster_ground = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local line_count = ability:GetSpecialValueFor("line_count")
	local travel_distance = ability:GetSpecialValueFor("travel_distance")

	EmitSoundOn(sound_cast, caster)

	-- 地面和人物特效
	local particle_caster_souls_fx = ParticleManager:CreateParticle(particle_caster_souls, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 1, Vector(lines, 0, 0))
	ParticleManager:SetParticleControl(particle_caster_souls_fx, 2, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_caster_souls_fx)

	local particle_caster_ground_fx = ParticleManager:CreateParticle(particle_caster_ground, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_caster_ground_fx, 1, Vector(lines, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx)

	--[[ 后面可能有用，别删
	local modifier_souls_handler
	local stacks
	local necro_ability
	local max_souls

	if caster:HasModifier(modifier_souls) then
		modifier_souls_handler = caster:FindModifierByName(modifier_souls)
		if modifier_souls_handler then
			stacks = modifier_souls_handler:GetStackCount()
			necro_ability = modifier_souls_handler:GetAbility()
		max_souls = modifier_souls_handler.total_max_souls
		end
	end
	

	-- If the modifier was not found, Requiem fails (no souls to release).
	if not modifier_souls_handler then
		return nil
	end
	]]

	
	-- 计算并释放第一个投射物
	local line_position = caster:GetAbsOrigin() + caster:GetForwardVector() * travel_distance
	CreateRequiemSoulLine(caster, ability, line_position)

	-- 计算并释放其他投射物
	local qangle_rotation_rate = 360 / line_count
	for i = 1, line_count - 1 do
		local qangle = QAngle(0, qangle_rotation_rate, 0)
		line_position = RotatePosition(caster:GetAbsOrigin(), qangle, line_position)
		CreateRequiemSoulLine(caster, ability, line_position)
	end
end

function HeavenlyExecution:OnProjectileHit_ExtraData(target, location, extra_data)
	if not target then
		return nil
	end


	local caster = self:GetCaster()
	local ability = self
	--获得Allez的当前等级技能伤害
	local associated_ability = caster:FindAbilityByName("LightRose")
	local damage = associated_ability:GetSpecialValueFor("LightRose_damage_multiple")*caster:GetAgility()

	local damageTable = {victim = target,
						damage = damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						attacker = caster,
						ability = ability
						}

	local damage_dealt = ApplyDamage(damageTable)
end


function CreateRequiemSoulLine(caster, ability, line_end_position)
	local particle_lines = "particles/units/heroes/hero_vengeful/vengeful_wave_of_2_terror.vpcf"
	local travel_distance = ability:GetSpecialValueFor("travel_distance")
	local lines_starting_width = ability:GetSpecialValueFor("lines_starting_width")
	local lines_end_width = ability:GetSpecialValueFor("lines_end_width")
	local lines_travel_speed = ability:GetSpecialValueFor("lines_travel_speed")


	local max_distance_time = travel_distance / lines_travel_speed
	local velocity = (line_end_position - caster:GetAbsOrigin()):Normalized() * lines_travel_speed


	projectile_info = {Ability = ability,
					   EffectName = particle_lines,
					   vSpawnOrigin = caster:GetAbsOrigin(),
					   fDistance = travel_distance,
					   fStartRadius = lines_starting_width,
					   fEndRadius = lines_end_width,
					   Source = caster,
					   bHasFrontalCone = false,
					   bReplaceExisting = false,
					   iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					   iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					   iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					   bDeleteOnHit = false,
					   vVelocity = velocity,
					   bProvidesVision = false
					   }

	ProjectileManager:CreateLinearProjectile(projectile_info)

	-- 投射物特效
	--[[local particle_lines_fx = ParticleManager:CreateParticle(particle_lines, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_lines_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_lines_fx, 1, velocity)
	ParticleManager:SetParticleControl(particle_lines_fx, 2, Vector(0, max_distance_time, 0))
	ParticleManager:ReleaseParticleIndex(particle_lines_fx)]]--

end