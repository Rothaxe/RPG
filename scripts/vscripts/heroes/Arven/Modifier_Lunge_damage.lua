Modifier_Lunge_damage = Modifier_Lunge_damage or class({})

function Modifier_Lunge_damage:IsHidden()	
	return true 
end
function Modifier_Lunge_damage:IsPurgable()	
	return false 
end

function Modifier_Lunge_damage:OnCreated()
	if not IsServer() then 
		return 
	end
	
	if self:GetAbility() then
		self.damage	= self:GetAbility():GetSpecialValueFor("damagemultiple") * self:GetAbility():GetCaster():GetAttackDamage()
	end
end

function Modifier_Lunge_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE}
end

function Modifier_Lunge_damage:GetModifierOverrideAttackDamage()
	return self.damage
end