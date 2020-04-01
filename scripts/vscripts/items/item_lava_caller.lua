item_lava_caller = class({})
LinkLuaModifier("modifier_item_lava_caller", "items/item_lava_caller", LUA_MODIFIER_MOTION_NONE)

function item_lava_caller:GetIntrinsicModifierName()
	return "modifier_item_lava_caller"
end




---------------------------------------------
--		modifier_item_lava_caller
---------------------------------------------
modifier_item_lava_caller = modifier_item_lava_caller or class({})

function modifier_item_lava_caller:IsHidden() return false end
function modifier_item_lava_caller:IsPurgable() return false end
function modifier_item_lava_caller:IsDebuff() return false end
function modifier_item_lava_caller:RemoveOnDeath() return false end
function modifier_item_lava_caller:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lava_caller:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}
	return decFuncs
end

function modifier_item_lava_caller:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_lava_caller:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_lava_caller:GetModifierBaseAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_lava_caller:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_greendamage")
end


--属性库
--[[
MODIFIER_PROPERTY_STATS_AGILITY_BONUS	修改敏捷
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS	修改智力
MODIFIER_PROPERTY_STATS_STRENGTH_BONUS	修改力量
MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE	修改基础攻击力
MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE	修改基础攻击伤害
MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS	增加护甲
MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE	修改附加攻击力

MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL	所有魔法攻击无效
MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL	所有物理攻击无效
MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE	所有神圣伤害无效
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS	修改攻击范围
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE	攻击距离增益（不叠加）
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT	修改攻击速度
MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT	设定基础攻击间隔

MODIFIER_PROPERTY_BASE_MANA_REGEN	修改基础魔法回复数值，对百分比回魔有影响
MODIFIER_PROPERTY_CAST_RANGE_BONUS	施法距离增益
MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE	改变技能数值
MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING	冷却时间百分比堆叠
MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT	减少冷却时间
MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE	按百分比修改攻击力，负数降低攻击，正数提高攻击
MODIFIER_PROPERTY_DISABLE_AUTOATTACK	禁止自动攻击
MODIFIER_PROPERTY_DISABLE_HEALING	禁止生命回复(1为禁止)
MODIFIER_PROPERTY_DISABLE_TURNING	禁止转身
MODIFIER_PROPERTY_EVASION_CONSTANT	闪避
ODIFIER_PROPERTY_HEALTH_BONUS	修改目前血量
MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT	固定的生命回复数值
MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE	根据装备带来的最大血量所产生的血量回复数值
MODIFIER_PROPERTY_INVISIBILITY_LEVEL	隐身等级？
MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS	魔法抗性，对神圣伤害无效，可以累加
MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE	魔法输出百分比（百分比法伤增益/减益）
MODIFIER_PROPERTY_MAX_ATTACK_RANGE	最大攻击距离增益
MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE	设置移动速度
MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE	设定基础移动速度
MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT	增加移动速度数值
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE	百分比增加移动速度，自身不叠加
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE	独立百分比增加移动速度，不叠加
MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE	增加移动速度数值，不叠加，物品版本
MODIFIER_PROPERTY_OVERRIDE_ANIMATION	强制播放模型动作
MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK	数值减免伤害？
MODIFIER_PROPERTY_POST_ATTACK	增加攻击力？
MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT	以增加伤害的方式修改伤害值，不计入暴击计算
MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE	致命一击
]]--