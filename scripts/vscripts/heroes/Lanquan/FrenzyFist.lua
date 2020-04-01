FrenzyFist = FrenzyFist or class({})

require 'helper/helperfunc'
LinkLuaModifier("modifier_frenzy", "heroes/Lanquan/FrenzyFist.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frenzy_beiqi", "heroes/Lanquan/FrenzyFist.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_lianji", "heroes/Lanquan/FrenzyFist.lua", LUA_MODIFIER_MOTION_NONE)

function FrenzyFist:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function FrenzyFist:OnOwnerSpawned()
	local caster = self:GetCaster()
	if self:GetLevel() > 0 then
		if not caster:HasModifier("flag_status") then
			caster:AddNewModifier(caster, self, "modifier_frenzy_beiqi", {})
		end
	end
end
function FrenzyFist:OnUpgrade()
	local caster = self:GetCaster()
	local flag = caster:FindModifierByName("flag_status")
	if flag then
		if not caster:HasModifier("modifier_frenzy") then 
			caster:AddNewModifier(caster, self, "modifier_frenzy", {})
		end
	else
		if not caster:HasModifier("modifier_frenzy_beiqi") then 
			caster:AddNewModifier(caster, self, "modifier_frenzy_beiqi", {})
		end
	end
end

---------------------------------------------------------------------------------------------------
--插旗被动修饰器
--连击delay目前暂定为0.1， 如果后期攻速变快可能要调整（重点测试）
modifier_frenzy = modifier_frenzy or class({})

function modifier_frenzy:OnCreated()
	if IsServer() then

	end
end

function modifier_frenzy:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_berserkers_blood.vpcf"
end

function modifier_frenzy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_frenzy:DeclareFunctions()
	local decFuncs =
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		}
	return decFuncs
end

function modifier_frenzy:OnAttackLanded( params )
	if IsServer() and self:GetParent():IsAlive() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = params.target

		if (params.attacker == caster) and caster:IsRealHero() and (params.target:GetTeamNumber() ~= caster:GetTeamNumber()) and not caster:PassivesDisabled() then
			
			--连击
			local lianji_perc = ability:GetSpecialValueFor("geminate_perc") 
			--计算大招释放时的连击概率
			local warcry = caster:FindModifierByName("modifier_warcry")
			local bonus_chance
			if warcry then
				bonus_chance = warcry:GetAbility():GetSpecialValueFor("lianji_chance_perc") / 100
			end

			local chance
			if bonus_chance ~= nil then
				chance = lianji_perc * (1 + bonus_chance)
			else
				chance = lianji_perc
			end
			local success = RollPercentage(chance)
			if success then
				print("success")
				local delay = ability:GetSpecialValueFor("geminate_delay")
				self:StartIntervalThink(delay)
			end
		end
	end 
end

function modifier_frenzy:OnIntervalThink()
	local caster = self:GetParent()
	local target = caster:GetAttackTarget()
	if target ~= nil and target:IsAlive() then
		--替身特效
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() )
		ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
		local success_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt__2ult.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControl(success_pfx, 2, caster:GetAbsOrigin())
		--攻击
		caster:PerformAttack(target, true, true, true, false, false, false, false)
		self:StartIntervalThink(-1)
	end	
end


function modifier_frenzy:GetModifierMoveSpeedBonus_Percentage()
	local movespeed = self:GetAbility():GetSpecialValueFor("movespeed_bonus_perc")
	return movespeed
end


function modifier_frenzy:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
end

function modifier_frenzy:IsBuff() 			return true end
function modifier_frenzy:IsHidden() 		return false end
function modifier_frenzy:IsPurgable() 		return false end
function modifier_frenzy:IsPurgeException() return false end
function modifier_frenzy:IsStunDebuff() 	return false end
function modifier_frenzy:RemoveOnDeath() 	return true end

-----------------------------------------------------------------------------------
--背旗被动
modifier_frenzy_beiqi = modifier_frenzy_beiqi or class({})

function modifier_frenzy_beiqi:GetTexture()
	return "sven_great_cleave"
end

function modifier_frenzy_beiqi:OnCreated()
	if IsServer() then

	end
end

function modifier_frenzy_beiqi:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_berserkers_blood.vpcf"
end

function modifier_frenzy_beiqi:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_frenzy_beiqi:DeclareFunctions()
	local decFuncs =
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
		}
	return decFuncs
end

function modifier_frenzy_beiqi:OnAttackLanded( params )
	print("Current attack_damage:" .. params.damage)
	if IsServer() and self:GetParent():IsAlive() then
		--分裂攻击
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if (params.attacker == caster) and caster:IsRealHero() and (params.target:GetTeamNumber() ~= caster:GetTeamNumber()) and not caster:PassivesDisabled() then
			local cleave_particle = "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
			local cleave_damage_pct = ability:GetSpecialValueFor("cleave_perc") / 100
			local cleave_radius_start = ability:GetSpecialValueFor("cleave_starting_width")
			local cleave_radius_end = ability:GetSpecialValueFor("cleave_ending_width")
			local cleave_distance = ability:GetSpecialValueFor("cleave_distance")
			DoCleaveAttack( params.attacker, params.target, ability, (params.damage * cleave_damage_pct), cleave_radius_start, cleave_radius_end, cleave_distance, cleave_particle )
		end

	end 
end

function modifier_frenzy_beiqi:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_frenzy_beiqi:IsBuff() 			return true end
function modifier_frenzy_beiqi:IsHidden() 			return false end
function modifier_frenzy_beiqi:IsPurgable() 		return false end
function modifier_frenzy_beiqi:IsPurgeException() 	return false end
function modifier_frenzy_beiqi:IsStunDebuff() 		return false end
function modifier_frenzy_beiqi:RemoveOnDeath() 		return true end