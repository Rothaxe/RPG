LinkLuaModifier("modifier_judgement_debuff", "heroes/Arven/modifier_judgement_debuff.lua", LUA_MODIFIER_MOTION_NONE)

if Modifier_Twine == nil then
    Modifier_Twine = class({})
end


function Modifier_Twine:OnCreated()
	if IsServer() then
	local debuff = self:GetParent():FindModifierByName("modifier_judgement_debuff")
		if debuff ~= nil then
		debuff:ForceRefresh()
		end
	self:StartIntervalThink(1)
	end
end

function Modifier_Twine:OnIntervalThink()
	if IsServer() then
	local damage = {
		victim = self:GetParent(),
		attacker = self:GetAbility():GetCaster(),
		damage = self:GetAbility():GetSpecialValueFor("damage_per_sec_multiple")*self:GetAbility():GetCaster():GetAgility(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	}
	ApplyDamage(damage)
	local enemy = self:GetParent()
	local caster = self:GetAbility():GetCaster()
	local oldhp = caster:GetHealth()
	local maxhp = caster:GetMaxHealth()
	local debuff = enemy:FindModifierByName("modifier_judgement_debuff")
		if enemy:HasModifier("modifier_judgement_debuff") and oldhp < maxhp then
			print("abc")
			caster:SetHealth(oldhp + maxhp * 0.05)
		end
	end
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
