Modifier_Effect = Modifier_Effect or class({})

function Modifier_Effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function Modifier_Effect:IsPassive()
	return true
end

function Modifier_Effect:IsPurgable() 
	return false
end
--[[ 
function Modifier_Effect:IsHidden() 
	return true 
end
]]

function Modifier_Effect:OnCreated()
	self.blade1 = "particles/econ/items/lifestealer/ls_ti9_immortal_gold/ls_ti9_open_wounds_gold_swipe.vpcf"
	self.blade2 = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold_swipe_dark.vpcf"
end

function Modifier_Effect:DeclareFunctions() 
	return {
	MODIFIER_EVENT_ON_ATTACK,
	}
end

function Modifier_Effect:OnAttack()
	local success = RollPercentage(50)
	if success then 
		self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
		local blade2 = ParticleManager:CreateParticle(self.blade2, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, self:GetCaster())
		ParticleManager:SetParticleControl(blade2, 1, self:GetCaster():GetAbsOrigin())
		self:AddParticle(blade2, false, false, -1, true, false)
	else 
		self:GetCaster():StartGesture(ACT_DOTA_ATTACK2)
		local blade1 = ParticleManager:CreateParticle(self.blade1, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, self:GetCaster())
		ParticleManager:SetParticleControl(blade1, 1, self:GetCaster():GetAbsOrigin()) 
		self:AddParticle(blade1, false, false, -1, true, false)
	end
end


