BloodCryDrag = class({})
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)
function BloodCryDrag: OnSpellStart()
	local radius = self:GetSpecialValueFor("radius")
	local caster = self:GetCaster()
	local position = caster:GetOrigin()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
			self:OnHit(enemy, damage)
	end
	local blast_pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/blink_dagger_end_ti6_vacuum.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, position)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)
		EmitSoundOnLocationWithCaster( position, "Ability.LightStrikeArray", caster )
end

function BloodCryDrag: OnHit(target, damage)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local ability = self
	local target_loc = target:GetAbsOrigin()
	local parent_loc	= self:GetCaster():GetAbsOrigin()
	local distance = (target_loc-parent_loc):Length2D()

	--击退
		knockback_properties = {
			 center_x 			= parent_loc.x,
			 center_y 			= parent_loc.y,
			 center_z 			= parent_loc.z,
			 duration 			= 0.5,
			 knockback_duration = 0.5,
			 knockback_distance = -distance,
			 knockback_height 	= 50,
			 should_stun = 1,
			 effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
		}
	local knockback_modifier = target:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)
end