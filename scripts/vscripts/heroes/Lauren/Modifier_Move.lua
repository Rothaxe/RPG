Modifier_Move = class({})
--Z轴待改进 

function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end

function Modifier_Move:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
end

function Modifier_Move:OnCreated()
	self.ability = self:GetAbility()
	self.speed = self.ability:GetSpecialValueFor("speed") * FrameTime()
	self.distance = self.ability:GetSpecialValueFor("distance")
	self.caster = self:GetParent()
	self.ground_point = self.caster:GetAbsOrigin().z
	--local height = self:GetAbility():GetSpecialValueFor("height")
	--local half_time = self.distance / 2 / self.speed
	--self.vertical_speed = height / half_time
	self.vertical_speed = self.ability:GetSpecialValueFor("vertical_speed") * FrameTime()

	if IsServer() then 
		Timer(FrameTime(), function()
			self.walk_traveled_distance = 0

			if self.direction ~= nil then
				self:StartIntervalThink(FrameTime())
			else 
				print("Error: nil direction value")
			end
		end)
	end
end

function Modifier_Move:OnIntervalThink()
	local ability = self.ability
	local caster = self.caster
		-- Distance calculations
		-- Saving the data in the ability

	local walk_distance = self.distance
	local walk_speed = self.speed
	local walk_direction = self.direction
	local walk_traveled_distance = self.walk_traveled_distance

	if walk_traveled_distance < walk_distance then
		local newPos = caster:GetAbsOrigin() - walk_direction * walk_speed
		--z轴运动
		if walk_traveled_distance < walk_distance / 2 then
			newPos.z = caster:GetOrigin().z + self.vertical_speed
		else
			newPos.z = caster:GetOrigin().z - self.vertical_speed
		end
		--修复z轴
		if newPos.z < GetGroundHeight( caster:GetOrigin(), self:GetParent() ) then 
			newPos.z = GetGroundHeight( caster:GetOrigin(), self:GetParent() )
		end

		caster:SetOrigin(newPos)
		print(newPos)
		self.walk_traveled_distance = walk_traveled_distance + walk_speed
	else
		caster:InterruptMotionControllers(false)
	end
	--caster:AddNewModifier(caster, self, "Modifier_fightback", {duration = 2})
end

function Modifier_Move:CheckState()
	local state = {
	[MODIFIER_STATE_ROOTED] = true,
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return state
end


function Modifier_Move:IsPurgable() 
	return false 
end

function Modifier_Move:IsDebuff() 
	return false 
end

function Modifier_Move:IsHidden()
	return true
end