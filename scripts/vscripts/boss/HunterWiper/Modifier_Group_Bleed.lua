Modifier_Group_Bleed = class({})

function Modifier_Group_Bleed:IsPurgable() 
	return false 
end

function Modifier_Group_Bleed:IsDebuff() 
	return true 
end

function Modifier_Group_Bleed:IsHidden()
	return false
end

function Modifier_Group_Bleed:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end


function Modifier_Group_Bleed:OnCreated(keys)
	if IsServer() then
		local damage_interval = self:GetAbility():GetLevelSpecialValueFor("damage_interval", self:GetAbility():GetLevel() - 1 )
		if self:GetParent().position == nil then
			self:GetParent().position = self:GetParent():GetAbsOrigin()
		end
		self:StartIntervalThink(damage_interval)

	end
end

function Modifier_Group_Bleed:OnIntervalThink()
	local movement_damage_pct = self:GetAbility():GetLevelSpecialValueFor( "movement_damage_pct", self:GetAbility():GetLevel() - 1 )/100
	local damage_cap_amount = self:GetAbility():GetLevelSpecialValueFor( "damage_cap_amount", self:GetAbility():GetLevel() - 1 )
	local damage = 0
	local caster = self:GetAbility():GetCaster()
	

	local distance = (self:GetParent().position - self:GetParent():GetAbsOrigin()):Length2D()
	if distance <= damage_cap_amount and distance > 0 then
		damage = distance * movement_damage_pct
	end
		self:GetParent().position = self:GetParent():GetAbsOrigin()

	if damage ~= 0 then
		ApplyDamage({
			victim = self:GetParent(), 
			attacker = caster, 
			damage = damage, 
			damage_type = self:GetAbility():GetAbilityDamageType()
			})
	end
end

