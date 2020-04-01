modifier_Bleed = class({})

function modifier_Bleed:IsPurgable() 
	return false 
end

function modifier_Bleed:IsDebuff() 
	return true 
end

function modifier_Bleed:IsHidden()
	return false
end

function modifier_Bleed:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_Bleed:OnCreated(keys)
	if IsServer() then
		local dot_interval = self:GetAbility():GetLevelSpecialValueFor("dot_interval", self:GetAbility():GetLevel() - 1 )
		self:StartIntervalThink(dot_interval)

	end
end

function modifier_Bleed:OnIntervalThink()
	local damage_perdot = self:GetAbility():GetLevelSpecialValueFor("damage_perdot", self:GetAbility():GetLevel() - 1 )
		ApplyDamage({
			victim = self:GetParent(), 
			attacker = caster, 
			damage = damage_perdot, 
			damage_type = self:GetAbility():GetAbilityDamageType()
			})
end

