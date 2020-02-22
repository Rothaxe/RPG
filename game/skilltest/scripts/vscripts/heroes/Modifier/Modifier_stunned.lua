Modifier_stunned = class({})

--------------------------------------------------------------------------------

function Modifier_stunned:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function Modifier_stunned:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function Modifier_stunned:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

--------------------------------------------------------------------------------

function Modifier_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function Modifier_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function Modifier_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function Modifier_stunned:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end