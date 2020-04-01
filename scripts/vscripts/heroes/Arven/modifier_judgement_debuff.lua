modifier_judgement_debuff =modifier_judgement_debuff or class({})

function modifier_judgement_debuff:OnCreated()
	self.caster = self:GetCaster()
	self.move_slow = self:GetAbility():GetSpecialValueFor("slowrate")
	self.damage = self:GetAbility():GetSpecialValueFor("Debuff_damage_multiple")*self.caster:GetAgility()
end

function modifier_judgement_debuff:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED}
	return funcs
end

function modifier_judgement_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.move_slow
end

function modifier_judgement_debuff:OnAttacked(keys)
	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local ultimate = caster:FindAbilityByName("HeavenlyExecution")
		local cooldown_remaining = ultimate:GetCooldownTimeRemaining()
		local cooldown_reduction = 0.5
		if caster == attacker and target == self:GetParent() then 
			if ultimate then
				local cooldown_remaining = ultimate:GetCooldownTimeRemaining()
				ultimate:EndCooldown()
				if cooldown_remaining > cooldown_reduction then
				ultimate:StartCooldown( cooldown_remaining - cooldown_reduction )
				end
			end

			self:IncrementStackCount()
			local stack = self:GetStackCount()
			if stack >= 4 then
				--替身
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() )
			ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() )
			ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

			ApplyDamage({
			attacker = caster, 
			victim = target, 
			damage = self.damage, 
			damage_type = DAMAGE_TYPE_PURE, 
			damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY
			})
			self:SetStackCount(0)
			end
		end

	end

end



function modifier_judgement_debuff:GetEffectName() return "particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf" end
function modifier_judgement_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_judgement_debuff:IsHidden() return false end
function modifier_judgement_debuff:IsDebuff() return true end
function modifier_judgement_debuff:IsPurgable() return true end