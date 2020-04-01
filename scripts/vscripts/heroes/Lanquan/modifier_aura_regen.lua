--同种光环不叠加：line17
modifier_aura_regen = modifier_aura_regen or class({})

function modifier_aura_regen:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
		self.effect = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
	end
end

function modifier_aura_regen:GetEffectName() 
	return self.effect
end

--同种光环不叠加写这里
function modifier_aura_regen:GetAuraEntityReject(hEntity)	
	if not IsServer() then 
		return false
	end
end

function modifier_aura_regen:IsHidden() 			return true end
function modifier_aura_regen:Isbuff() 				return true end
function modifier_aura_regen:IsPurgable() 			return false end
function modifier_aura_regen:DestroyOnExpire() 		return true end
function modifier_aura_regen:IsAura() 				return true end
function modifier_aura_regen:GetModifierAura()		return "modifier_regen" end
function modifier_aura_regen:GetAuraRadius()		return self.radius end
--function modifier_aura_regen:GetAuraSearchFlags()	return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_aura_regen:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_aura_regen:GetAuraSearchType()	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_aura_regen:IsAuraActiveOnDeath() 	return false end
function modifier_aura_regen:GetAuraDuration()		return 0 end

----------------------------------------------------------------------------------------------
--次级修饰器
--TODO:特效 图标
modifier_regen = modifier_regen or class({})

function modifier_regen:OnCreated() 
	if not IsServer() then
		return
	end
end

function modifier_regen:GetTexture()
	return "legion_commander_duel"
end
function modifier_regen:GetEffectName()
	return
end

function modifier_regen:GetEffectAttachType()
	return
end

--固定回血
function modifier_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
	return funcs
end

function modifier_regen:GetModifierConstantHealthRegen()
	--if IsServer() then
	return self:GetAbility():GetSpecialValueFor("regen")
	--end
end


function modifier_regen:IsHidden() 				return false end
function modifier_regen:Isbuff() 				return true end
function modifier_regen:IsPurgable() 			return false end