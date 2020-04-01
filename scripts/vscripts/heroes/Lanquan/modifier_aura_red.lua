--同种光环不叠加：line17
modifier_aura_red = modifier_aura_red or class({})

function modifier_aura_red:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
		self.effect = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
	end
end

function modifier_aura_red:GetEffectName() 
	return self.effect
end

--同种光环不叠加写这里
function modifier_aura_red:GetAuraEntityReject(hEntity)	
	if not IsServer() then 
		return false
	end
end

function modifier_aura_red:IsHidden() 				return true end
function modifier_aura_red:Isbuff() 				return true end
function modifier_aura_red:IsPurgable() 			return false end
function modifier_aura_red:DestroyOnExpire() 		return true end
function modifier_aura_red:IsAura() 				return true end
function modifier_aura_red:GetModifierAura()		return "modifier_red" end
function modifier_aura_red:GetAuraRadius()			return self.radius end
--function modifier_aura_red:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_aura_red:GetAuraSearchTeam()		return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_aura_red:GetAuraSearchType()		return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_aura_red:IsAuraActiveOnDeath() 	return false end
function modifier_aura_red:GetAuraDuration()		return 0 end

---------------------------------------------------------------------------------------------------------------
--次级修饰器
--TODO:特效,图标
modifier_red = modifier_red or class({})

function modifier_red:OnCreated()

	if IsServer() then
	end
end

function modifier_red:GetTexture()
	return "legion_commander_duel"
end
function modifier_red:GetEffectName()
	return
end

function modifier_red:GetEffectAttachType()
	return
end

--百分比减伤
function modifier_red:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_red:GetModifierIncomingDamage_Percentage()
	local reduce_perc = self:GetAbility():GetSpecialValueFor("reduce_percentage")
	return reduce_perc
end


function modifier_red:IsHidden() 			return false end
function modifier_red:Isbuff() 				return true end
function modifier_red:IsPurgable() 			return false end