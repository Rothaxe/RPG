acidspray = class({})
LinkLuaModifier("modifier_acidspray_thinker", "boss/spiderboss/modifier_acidspray_thinker.lua", LUA_MODIFIER_MOTION_NONE)

function acidspray:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()
	local team_id = caster:GetTeamNumber()
	local duration = ability:GetSpecialValueFor("duration")
	local thinker = CreateModifierThinker(caster, self, "modifier_acidspray_thinker", {duration = duration}, point, team_id, false)
	return true
end

