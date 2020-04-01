--2020.03.19
--极端情况bug（待测试）：如果目标地点和自身坐标高度差距太大，direction会带有z轴，可能会带来异常z轴变动


modifier_custom_knockback = modifier_custom_knockback or class({})

function modifier_custom_knockback:OnCreated(keys)
	if IsServer() then
		--载入所有键值
		local center_x = keys.center_x
		local center_y = keys.center_y
		local center_z = keys.center_z
		local knockback_duration = keys.knockback_duration
		self.duration = keys.duration
		self.knockback_distance = keys.knockback_distance
		local knockback_height = keys.knockback_height
		self.effect_name = keys.effect_name
		self.attach_type = keys.attach_type --e.g.PATTACH_ABSORIGIN_FOLLOW(Default setting)
		self.animation = keys.animation    	--e.g.ACT_DOTA_ATTACK
		--以下键值: all true/false, 默认false
		self.should_stun = (keys.should_stun == 1 and {true} or {false})[1]
		self.stun_status = (keys.stun_status == 1 and {true} or {false})[1]
		self.xiangwei = (keys.xiangwei == 1 and {true} or {false})[1]
		--[[
			--以下无效，待研究
		self.is_debuff = (keys.is_debuff == 1 and {true} or {false})[1]
		self.is_hidden = (keys.is_hidden == 1 and {true} or {false})[1]
		self.is_purgable = (keys.is_purgable == 1 and {true} or {false})[1]
		]]
		

		--键值转换
		self.caster = self:GetParent()
		local target_point = Vector(center_x, center_y, center_z)
		self.direction =  (self.caster:GetAbsOrigin() - target_point):Normalized()

		if self.knockback_distance < 0 then
			self.direction = -self.direction
			self.knockback_distance = -self.knockback_distance
		end

		local speed = self.knockback_distance / knockback_duration
		self.speed_per_frame = speed * FrameTime()

		local vertical_speed = knockback_height / (knockback_duration / 2.0)
		self.v_s_per_frame = vertical_speed * FrameTime()


		--特效
		if self.should_stun then
			self.stun = ParticleManager:CreateParticle("particles/generic_gameplay/generic_stunned.vpcf", PATTACH_OVERHEAD_FOLLOW, self.caster)
		end

		if self.effect_name ~= nil then
			local attach_type = PATTACH_ABSORIGIN_FOLLOW
			if self.attach_type ~= nil then 
				attach_type = self.attach_type
			else
				print("No attach_type is found!!!")
			end
			self.particle = ParticleManager:CreateParticle(self.effect_name, attach_type, self.caster)
		end
		--开始位移
		self.traveled_distance = 0
		self.v_distance = self.caster:GetOrigin().z
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_custom_knockback:OnIntervalThink()
	local caster = self.caster
	local distance = self.knockback_distance
	local traveled_distance = self.traveled_distance


	--位移
	if traveled_distance < distance then
		--击退期间动画
		if self.animation ~= nil then
			caster:StartGesture(self.animation)
		end	

		local newPos = caster:GetAbsOrigin() + self.direction * self.speed_per_frame
		--z轴运动
		if traveled_distance < distance / 2.0 then
			newPos.z = caster:GetOrigin().z + self.v_s_per_frame
		else
			newPos.z = caster:GetOrigin().z - self.v_s_per_frame
		end
		
		--修复z轴
		if newPos.z < GetGroundHeight(caster:GetOrigin(), caster) then 
			newPos.z = GetGroundHeight(caster:GetOrigin(), caster)
		end
		caster:SetOrigin(newPos)
		--print(caster:GetOrigin())
		self.traveled_distance = traveled_distance + self.speed_per_frame
	else
		FindClearSpaceForUnit(caster, caster:GetOrigin(), true)
		--停止计时
		self:StartIntervalThink(-1)
	end
end


function modifier_custom_knockback:CheckState()
	local state = {
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = self.xiangwei,
	}
	if self.should_stun or self.stun_status then
		state[MODIFIER_STATE_STUNNED] = true;
	end
	return state
end

function modifier_custom_knockback:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
	return funcs
end

function modifier_custom_knockback:GetOverrideAnimation()
	if self.should_stun then
		return ACT_DOTA_DISABLED
	end
end


function modifier_custom_knockback:IsDebuff()
	--return self.is_debuff
	return true
end

function modifier_custom_knockback:IsPurgable()
	--return self.is_purgable
	return true
end

function modifier_custom_knockback:IsHidden()
	--return self.is_hidden
	return true
end

function modifier_custom_knockback:OnDestroy()
	--print("destroy")
	if IsServer() then
		if self.stun ~= nil then
			ParticleManager:DestroyParticle(self.stun, true)
		end
		if self.effect_name ~= nil then
			ParticleManager:DestroyParticle(self.particle, true)
		end
	end
end


