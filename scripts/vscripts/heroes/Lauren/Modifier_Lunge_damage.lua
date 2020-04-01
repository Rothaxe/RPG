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
		local buff = self:GetParent():FindModifierByName("Modifier_Lunge_buff")
		local damage_increased = self:GetAbility():GetSpecialValueFor("damage_increased")
		self.damage	= self:GetAbility():GetSpecialValueFor("damage")
		--print(self.damage)
		if buff ~= nil then
			self.damage = self.damage * (1 + damage_increased)
			--print(self.damage)
		end
	else
		self.damage = 0
	end
end

function Modifier_Lunge_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE}
end

function Modifier_Lunge_damage:GetModifierOverrideAttackDamage()
	return self.damage
end