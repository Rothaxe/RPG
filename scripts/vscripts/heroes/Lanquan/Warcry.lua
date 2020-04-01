Warcry = Warcry or class({})

LinkLuaModifier("modifier_warcry", "heroes/Lanquan/Warcry.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warcry_aura", "heroes/Lanquan/Warcry.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warcry_aura_buff", "heroes/Lanquan/Warcry.lua", LUA_MODIFIER_MOTION_NONE)

function Warcry:OnUpgrade()

	--身上背旗无法释放
	if not self:GetCaster():HasModifier("flag_status") then
		self:SetActivated(false)
	else
		self:SetActivated(true)
	end
end

function Warcry:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	--大招自身状态
	caster:AddNewModifier(caster, self, "modifier_warcry", {duration = duration})

	--给旗上光环
	local flag_status = caster:FindModifierByName("flag_status")
	local flag_model = flag_status.flag_model
	local flag = Entities:FindByModel(nil, flag_model)
	flag:AddNewModifier(caster, self, "modifier_warcry_aura", {duration = duration})
end

--------------------------------------------------------------------
modifier_warcry = modifier_warcry or class({})

function modifier_warcry:OnCreated()
	if not IsServer() then return end
end

function modifier_warcry:DeclareFunctions()
	local func = 
		{
			--MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		}
	return func
end
--[[
function modifier_warcry:GetModifierAttackSpeedBonus_Constant()
	return 600
end
]]
function modifier_warcry:GetAttackSound()
	return "Hero_Alchemist.ChemicalRage.Attack"
end

function modifier_warcry:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("attack_interval")
end

function modifier_warcry:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_warcry:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_warcry:GetStatusEffectName()
	return "particles/status_fx/status_effect_chemical_rage.vpcf"
end

function modifier_warcry:StatusEffectPriority()
	return 10
end

function modifier_warcry:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_warcry:HeroEffectPriority()
	return 10
end


function modifier_warcry:IsBuff()			return true end
function modifier_warcry:IsHidden() 		return false end
function modifier_warcry:IsPurgable() 		return false end
function modifier_warcry:IsPurgeException() return false end
function modifier_warcry:IsStunDebuff() 	return false end
function modifier_warcry:RemoveOnDeath() 	return true end

------------------------------------------------------------------------
modifier_warcry_aura = modifier_warcry_aura or class({})
function modifier_warcry_aura:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
		self.effect = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
	end
end

function modifier_warcry_aura:GetEffectName() 
	return self.effect
end

--同种光环不叠加写这里
function modifier_warcry_aura:GetAuraEntityReject(hEntity)	
	if not IsServer() then 
		return false
	end
end

function modifier_warcry_aura:IsHidden() 			return true end
function modifier_warcry_aura:Isbuff() 				return true end
function modifier_warcry_aura:IsPurgable() 			return false end
function modifier_warcry_aura:DestroyOnExpire() 	return true end
function modifier_warcry_aura:IsAura() 				return true end
function modifier_warcry_aura:GetModifierAura()		return "modifier_warcry_aura_buff" end
function modifier_warcry_aura:GetAuraRadius()		return self.radius end
--function modifier_warcry_aura:GetAuraSearchFlags()	return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end
function modifier_warcry_aura:GetAuraSearchTeam()	return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_warcry_aura:GetAuraSearchType()	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_warcry_aura:IsAuraActiveOnDeath() return false end
function modifier_warcry_aura:GetAuraDuration()		return 0 end

------------------------------------------------------------------------
--次级修饰器
--TODO:特效 图标
modifier_warcry_aura_buff = modifier_warcry_aura_buff or class({})

function modifier_warcry_aura_buff:OnCreated() 
	if not IsServer() then
		return
	end
end

function modifier_warcry_aura_buff:GetTexture()
	return "legion_commander_duel"
end
function modifier_warcry_aura_buff:GetEffectName()
	return
end

function modifier_warcry_aura_buff:GetEffectAttachType()
	return
end

--固定回血
function modifier_warcry_aura_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_warcry_aura_buff:GetModifierConstantHealthRegen()
	--if IsServer() then
	return self:GetAbility():GetSpecialValueFor("regen")
	--end
end

function modifier_warcry_aura_buff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("reduce_perc")
end


function modifier_warcry_aura_buff:IsHidden() 				return false end
function modifier_warcry_aura_buff:Isbuff() 				return true end
function modifier_warcry_aura_buff:IsPurgable() 			return false end