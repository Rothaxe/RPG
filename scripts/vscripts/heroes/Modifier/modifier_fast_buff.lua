modifier_fast_buff = modifier_fast_buff or class({})

function modifier_fast_buff:GetEffectName() return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf" end

function modifier_fast_buff:OnCreated()
	self.caster = self:GetCaster()
	self.move_fast = self:GetAbility():GetSpecialValueFor("movespeedpct")
	self.attack_fast = self:GetAbility():GetSpecialValueFor("atkspeedpct")

end

function modifier_fast_buff:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
	return funcs
end
function modifier_fast_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.move_fast
end

function modifier_fast_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attack_fast
end

function modifier_fast_buff:IsHidden() return false end
function modifier_fast_buff:Isbuff() return true end
function modifier_fast_buff:IsPurgable() return false end
function modifier_fast_buff:DestroyOnExpire() return true end

--加速光环
function modifier_fast_buff:IsAura() 					return true end
function modifier_fast_buff:GetModifierAura()			return "modifier_fast_buff" end
function modifier_fast_buff:GetAuraRadius()				return 1000 end
function modifier_fast_buff:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_fast_buff:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fast_buff:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fast_buff:IsAuraActiveOnDeath() 		return false end
function modifier_fast_buff:GetAuraDuration()			return 1 end
function modifier_fast_buff:GetAuraEntityReject(hEntity)	return hEntity == self:GetCaster() end 
