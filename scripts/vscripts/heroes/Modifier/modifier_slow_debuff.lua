modifier_slow_debuff =modifier_slow_debuff or class({})

function modifier_slow_debuff:OnCreated()
	self.caster = self:GetCaster()
	self.move_slow = self:GetAbility():GetSpecialValueFor("slowrate")
	self.attack_slow = self.move_slow
end

function modifier_slow_debuff:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
	return funcs
end
function modifier_slow_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_slow_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.attack_slow
end

function modifier_slow_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_slow_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_slow_debuff:IsHidden() return false end
function modifier_slow_debuff:IsDebuff() return true end
function modifier_slow_debuff:IsPurgable() return true end