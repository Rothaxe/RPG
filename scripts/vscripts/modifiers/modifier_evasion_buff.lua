modifier_evasion_buff = modifier_evasion_buff or class({})

function modifier_evasion_buff:GetEffectName() return "particles/bottle_ti8_ring_crystal2.vpcf" end

--[[function modifier_evasion_buff:OnCreated()
	local particle = ParticleManager:CreateParticle("particles/bottle_ti8_ring_crystal2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin() )
end]]--

function modifier_evasion_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT
		}

	return decFuncs
end

function modifier_evasion_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeedpct")
end

function modifier_evasion_buff:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("evasionrate")
end

