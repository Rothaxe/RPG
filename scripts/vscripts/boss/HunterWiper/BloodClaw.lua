BloodClaw = class({})

--modifier_BloodClaw

LinkLuaModifier("modifier_BloodClaw", "BloodClaw", LUA_MODIFIER_MOTION_NONE)
function BloodClaw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local damage = self:GetSpecialValueFor("spell_damage")

	local stuntime = self:GetSpecialValueFor("stun_time")

	local damagetable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL
	}
	ApplyDamage(damagetable)

	target:AddNewModifier(caster, self, "modifier_BloodClaw", {duration = stuntime})
end


modifier_BloodClaw = class({})

function modifier_BloodClaw:IsDebuff()
	return true 
end

function modifier_BloodClaw:IsStunDebuff()
	return true 
end

function modifier_BloodClaw:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true 
	}
		return state
end
