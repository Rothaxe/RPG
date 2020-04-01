BackJump = class({})

LinkLuaModifier("Modifier_FightBack", "heroes/Lauren/Modifier_FightBack.lua", LUA_MODIFIER_MOTION_NONE)

function BackJump:OnSpellStart()
	local ability = self
	local caster = self:GetCaster()
	print(caster)
	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	leap_direction = caster:GetForwardVector()
	leap_distance = ability:GetSpecialValueFor("leap_distance")
	leap_speed = ability:GetSpecialValueFor("leap_speed") 
	leap_traveled = 0
	leap_z = 0
	
	Timer( function()
		if leap_traveled < leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + leap_direction * leap_speed)
		leap_traveled = leap_traveled + leap_speed

		return 0.02
	else
		caster:InterruptMotionControllers(true)
		return
	end
	end)

end

function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
--[[function BackJump:LeapHorizonal()
	local caster = self:GetCaster()
	local ability = self

	Timer(FrameTime(), function()
		if leap_traveled < leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + leap_direction * leap_speed)
		leap_traveled = leap_traveled + leap_speed
	else
		caster:InterruptMotionControllers(true)
	end
	end)
end]]--

--[[Moves the caster on the vertical axis until movement is interrupted]]
--[[function BackJump:LeapVertical()
	local caster = self:GetCaster()
	local ability = self

	Timer(FrameTime(), function()
	-- For the first half of the distance the unit goes up and for the second half it goes down
	if leap_traveled < leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		leap_z = leap_z + leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,leap_z))
	else
		-- Go down
		leap_z = leap_z - leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,leap_z))
	end

		end)
end]]--