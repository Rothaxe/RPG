require('util/helperfunc')
modifier_Burn = class({})


function modifier_Burn:IsPurgable() 
	return true
end

function modifier_Burn:IsDebuff() 
	return true 
end

function modifier_Burn:IsHidden()
	return false
end

function modifier_Burn:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_Burn:OnCreated(keys)
	if IsServer() then
		local burn_interval = self:GetAbility():GetLevelSpecialValueFor("burn_interval", self:GetAbility():GetLevel() - 1 )
		self:StartIntervalThink(burn_interval)
	end
end

function modifier_Burn:OnIntervalThink()
	local caster = self:GetAbility():GetCaster()
	local burndamage_multiple = self:GetAbility():GetLevelSpecialValueFor("burndamage_multiple", self:GetAbility():GetLevel() - 1 ) 
	ApplyDamage({
			victim = self:GetParent(), 
			attacker = caster, 
			damage = burndamage_multiple * GetMaxAttr(caster), 
			damage_type = self:GetAbility():GetAbilityDamageType()
			})
end

