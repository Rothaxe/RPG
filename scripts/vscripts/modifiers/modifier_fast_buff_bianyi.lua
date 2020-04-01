modifier_fast_buff_bianyi = modifier_fast_buff_bianyi  or class({})

function modifier_fast_buff_bianyi :GetEffectName() return "particles/items_fx/aura_shivas.vpcf" end

function modifier_fast_buff_bianyi :OnCreated()
	self.caster = self:GetCaster()
	self.move_fast = 30
	self.attack_fast = 100

end

function modifier_fast_buff_bianyi :DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
	return funcs
end
function modifier_fast_buff_bianyi :GetModifierMoveSpeedBonus_Percentage()
	return self.move_fast
end

function modifier_fast_buff_bianyi :GetModifierAttackSpeedBonus_Constant()
	return self.attack_fast
end

function modifier_fast_buff_bianyi :IsHidden() return false end
function modifier_fast_buff_bianyi :Isbuff() return true end
function modifier_fast_buff_bianyi :IsPurgable() return false end
function modifier_fast_buff_bianyi :DestroyOnExpire() return true end

