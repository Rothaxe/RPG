Modifier_Lunge_Dash = Modifier_Lunge_Dash or class({})
require ('util/helperfunc')

function Modifier_Lunge_Dash:OnCreated()
	self.attack_modifier = "Modifier_Lunge_Slashes"
	--self.dash_particle = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
	self.dash_particle = "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
	self.hit_sound = "Hero_Pangolier.Swashbuckle.Damage"
	self.dash_speed = self:GetAbility():GetSpecialValueFor("dash_speed")
	self.range = self:GetAbility():GetSpecialValueFor("range")

	if IsServer() then
		self.time_elapsed = 0

		--等一帧时间获取技能传入的point
		Timer(FrameTime(), function()
			self.distance = (self:GetCaster():GetAbsOrigin() - self.target_point):Length2D()
			self.dash_time = self.distance / self.dash_speed
			self.direction = (self.target_point - self:GetCaster():GetAbsOrigin()):Normalized()

			--[[local dash = ParticleManager:CreateParticle(self.dash_particle, PATTACH_WORLDORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(dash, 0, self:GetCaster():GetAbsOrigin()) -- point 0: origin, point 2: sparkles, point 5: burned soil
			self:AddParticle(dash, false, false, -1, true, false)]]--
			self.dash = ParticleManager:CreateParticle(self.dash_particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			--ParticleManager:SetParticleControl(dash, 0, self:GetCaster():GetAbsOrigin())
			--ParticleManager:SetParticleControl(dash, 1, self.target_point) 
			self.frametime = FrameTime()
			self:StartIntervalThink(self.frametime)
		end)
	end
end

--滚的时候眩晕状态
function Modifier_Lunge_Dash:CheckState()
	state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
		--[MODIFIER_STATE_INVULNERABLE] = true 滚的时候无敌
	}
	return state
end

function Modifier_Lunge_Dash:IsHidden() 
	return true 
end

function Modifier_Lunge_Dash:IsPurgable() 
	return false 
end

function Modifier_Lunge_Dash:IsDebuff() 
	return false 
end

function Modifier_Lunge_Dash:IgnoreTenacity() 
	return true 
end

function Modifier_Lunge_Dash:IsMotionController() 
	return true 
end

function Modifier_Lunge_Dash:GetMotionControllerPriority() 
	return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM 
end

function Modifier_Lunge_Dash:OnIntervalThink()
	--[[
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end]]

	-- Horizontal motion
	self:HorizontalMotion(self:GetParent(), self.frametime)
end

function Modifier_Lunge_Dash:HorizontalMotion(me, dt)
	if IsServer() then 
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.dash_time then


			-- 如果没到时间，继续滚
			local new_location = self:GetCaster():GetAbsOrigin() + self.direction * self.dash_speed * dt
			self:GetCaster():SetAbsOrigin(new_location)
		else
			self:Destroy()
		end
	end
end

function Modifier_Lunge_Dash:OnRemoved()
	if IsServer() then
		FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetAbsOrigin(), true)

		self:GetCaster():SetForwardVector(self.direction)

		--播放戳的动画
		self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		ParticleManager:DestroyParticle(self.dash, true)

		local attack_modifier_handler = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), self.attack_modifier, {})

		--传目标
		attack_modifier_handler.target = target_unit
	end
end