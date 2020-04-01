spiderrush = class({})
require ('util/helperfunc')
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_firepath", "boss/spiderboss/modifier_firepath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_poisonpath", "boss/spiderboss/modifier_poisonpath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_acidspray_thinker", "boss/spiderboss/modifier_acidspray_thinker.lua", LUA_MODIFIER_MOTION_NONE)

function spiderrush:OnSpellStart()
	local caster = self:GetCaster()
	local caster_pos = caster:GetAbsOrigin()
	local target_pos = self:GetCursorPosition()
	local distance = (target_pos - caster_pos):Length2D()
	if IsServer() then
		caster:AddNewModifier(caster, self, "modifier_poisonpath", {duration = 4})
		knockback_properties = {
			 			center_x 			= target_pos.x,
			 			center_y 			= target_pos.y,
			 			center_z 			= target_pos.z,
			 			duration 			= 1,
			 			knockback_duration = 1,
			 			knockback_distance = -distance,
			 			knockback_height 	= 100,
			 			--should_stun = 1,
			 			stun_status = 0.9,
			 			effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
					}

		--播放动画并击退
		caster:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)

		--caster:AddNewModifier(caster, self, "modifier_firepath", {duration = 4})
	end
end

