

if Modifier_Twine == nil then
    Modifier_Twine = class({})
end


function Modifier_Twine:OnCreated()
	self:StartIntervalThink(1)
end

function Modifier_Twine:OnIntervalThink()
	local damage = {
		victim = self:GetParent(),
		attacker = self:GetAbility():GetCaster(),
		damage = self:GetAbility():GetSpecialValueFor("damage_per_sec"),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	}
	ApplyDamage(damage)
end

function Modifier_Twine:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function Modifier_Twine:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf" --待修改
end

--------------------------------------------------------------------------------

function Modifier_Twine:GetEffectAttachType()
	return PATTACH_CENTER_FOLLOW
end

--------------------------------------------------------------------------------

function Modifier_Twine:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function Modifier_Twine:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function Modifier_Twine:CheckState()
	local state = {
	[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end
