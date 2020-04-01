Crush = Crush or class({})
require ('helper/helperfunc')

function Crush:GetCastPoint()
	return self:GetSpecialValueFor("delay")
end

function Crush:OnSpellStart()
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("aoe_damage")*caster:GetStrength()
	local radius = self:GetSpecialValueFor("aoe_radius")
	local range = self:GetSpecialValueFor("cast_range")
	local xiguai_radius = self:GetSpecialValueFor("xiguai_radius")
	local flag_status = caster:FindModifierByName("flag_status")
	local point = self:GetCursorPosition()
	local distance = (point - caster:GetAbsOrigin()):Length2D()
	local cur_time = GameRules:GetGameTime()
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	local move_practicle = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
	local particle_damage = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local particle_gouhe = "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf"
	--距离过远重新计算
	if distance > range then
		point = caster:GetAbsOrigin() + range * direction
		distance = range
	end
	

	--计算每次计时间隔要走多少路
	local inteval = FrameTime()
	local speed = self:GetSpecialValueFor("speed")
	local vector_per_frame = direction * speed * inteval

	--记录位移时间
	local move_duration = distance / speed
	local curr_duration = 0

	--位移特效
	local particle_move_fx = ParticleManager:CreateParticle(move_practicle, PATTACH_ABSORIGIN_FOLLOW, caster)

	--背旗状态沟壑特效
	if flag_status == nil then
		local particle_gouhe_fx = ParticleManager:CreateParticle(particle_gouhe, PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(particle_gouhe_fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_gouhe_fx, 1, point)
		ParticleManager:SetParticleControl(particle_gouhe_fx, 3, Vector(0, 2, 0))
	end

	

	Timer(function()
		local pos = caster:GetAbsOrigin()

		--到达地点或者超过位移时间就停
		if (pos - point):Length2D() <= 50 or curr_duration >= move_duration then 
			FindClearSpaceForUnit(caster, pos, true)

			--删除特效
			ParticleManager:DestroyParticle(particle_move_fx, true)
			if particle_gouhe_fx then
				ParticleManager:ReleaseParticleIndex(particle_gouhe_fx)
			end

			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			--伤害特效
			local particle_damage_fx = ParticleManager:CreateParticle(particle_damage, PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(particle_damage_fx, 0, caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_damage_fx)
			for _, enemy in pairs(enemies) do 
				local info = {
					attacker = caster,
					victim = enemy,
					ability = self,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL
				}
				ApplyDamage(info)
			end
			return
		else
			move(caster, vector_per_frame, xiguai_radius, flag_status)
			curr_duration = curr_duration + inteval
			return inteval
		end
	end)
end

function move(caster, vector_per_frame, xiguai_radius, flag_status)
	local pos = caster:GetAbsOrigin()

	--如果背旗就聚怪
	if flag_status == nil then
		--吸怪
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, xiguai_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do 
			enemy:SetAbsOrigin(pos)
		end

		--TODO：沟壑特效
	end

	local newPos = pos + vector_per_frame
	if GridNav:CanFindPath(pos, newPos) then 
		caster:SetAbsOrigin(newPos)
	else
		FindClearSpaceForUnit(caster, newPos, true)
	end
	return GameRules:GetGameTime()
end