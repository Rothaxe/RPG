--同种光环不叠加：line17
modifier_aura_damage = modifier_aura_damage or class({})

function modifier_aura_damage:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
		self.effect = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
	end
end

function modifier_aura_damage:GetEffectName() 
	return self.effect
end

--同种光环不叠加写这里
function modifier_aura_damage:GetAuraEntityReject(hEntity)	
	if not IsServer() then 
		return false
	end
end

function modifier_aura_damage:IsHidden() 			return true end
function modifier_aura_damage:Isbuff() 				return true end
function modifier_aura_damage:IsPurgable() 			return false end
function modifier_aura_damage:DestroyOnExpire() 	return true end
function modifier_aura_damage:IsAura() 				return true end
function modifier_aura_damage:GetModifierAura()		return "modifier_damage" end
function modifier_aura_damage:GetAuraRadius()		return self.radius end
--function modifier_aura_damage:GetAuraSearchFlags()	return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_aura_damage:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_aura_damage:GetAuraSearchType()	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_aura_damage:IsAuraActiveOnDeath() return false end
function modifier_aura_damage:GetAuraDuration()		return 0 end

---------------------------------------------------------------------------------------------------------------
--次级修饰器
--TODO:特效,图标
modifier_damage = modifier_damage or class({})

function modifier_damage:OnCreated() 
	--[[if not IsServer() then
		return
	end]]
end

function modifier_damage:GetTexture()
	return "legion_commander_duel"
end
function modifier_damage:GetEffectName()
	return
end

function modifier_damage:GetEffectAttachType()
	return
end


function modifier_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_damage:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_perc")
end


function modifier_damage:IsHidden() 			return false end
function modifier_damage:Isbuff() 				return true end
function modifier_damage:IsPurgable() 			return false end