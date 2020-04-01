modifier_poisonpath = class({})

function modifier_poisonpath:IsPurgable() 
	return false 
end

function modifier_poisonpath:IsBuff() 
	return true 
end

function modifier_poisonpath:IsHidden()
	return true
end

function modifier_poisonpath:IsPurgable()	return false end

function modifier_poisonpath:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

-- IntervalThink only starts once self.firefly_thinker exists (which handles flame drops)
function modifier_poisonpath:OnIntervalThink()
	if IsServer() then
	print("interval")
	local caster = self:GetAbility():GetCaster()
	local ability = self:GetAbility()
	local point = caster:GetAbsOrigin()
	local team_id = caster:GetTeamNumber()
	local duration = ability:GetSpecialValueFor("duration")
	local thinker = CreateModifierThinker(caster, self:GetAbility(), "modifier_acidspray_thinker", {duration = duration}, point, team_id, false)
	--self.firefly_thinker = CreateModifierThinker(self:GetParent(), self:GetAbility(), "modifier_acidspray_thinker", {duration = 4}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
	end
end
