LinkLuaModifier( "modifier_evasion_buff" , "modifiers/modifier_evasion_buff.lua" , LUA_MODIFIER_MOTION_NONE )
modifier_evasion_aura = modifier_evasion_aura or class({})

function modifier_evasion_aura:OnCreated()
	self.caster = self:GetCaster()
end

function modifier_evasion_aura:IsHidden() return false end
function modifier_evasion_aura:Isbuff() return true end
function modifier_evasion_aura:IsPurgable() return false end
function modifier_evasion_aura:DestroyOnExpire() return true end

--加速光环
function modifier_evasion_aura:IsAura() 					return true end
function modifier_evasion_aura:GetModifierAura()			return "modifier_evasion_buff" end
function modifier_evasion_aura:GetAuraRadius()				return 800 end
function modifier_evasion_aura:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_evasion_aura:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_evasion_aura:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_evasion_aura:IsAuraActiveOnDeath() 		return false end
function modifier_evasion_aura:GetAuraDuration()			return 0.5 end
function modifier_evasion_aura:GetAuraEntityReject(hEntity)			
	if hEntity == self.caster then
			return false
	end
end
