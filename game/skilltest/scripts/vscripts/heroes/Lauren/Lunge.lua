Lunge = Lunge or class({})
LinkLuaModifier("Modifier_Lunge_Dash", "heroes/Lauren/Modifier_Lunge_Dash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_Slashes", "heroes/Lauren/Modifier_Lunge_Slashes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_damage", "heroes/Lauren/Modifier_Lunge_damage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_explosion", "heroes/Lauren/Modifier_Lunge_explosion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_buff", "heroes/Lauren/Modifier_Lunge_buff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_stunned", "heroes/Modifier/Modifier_stunned.lua", LUA_MODIFIER_MOTION_NONE)
function Lunge:GetAbilityTextureName()
	return "pangolier_swashbuckle"
end

--[[
function Lunge:GetAssociatedSecondaryAbilities()
	return ""
end
]]

function Lunge:GetManaCost(level)
	local manacost = self.BaseClass.GetManaCost(self, level)
	return manacost
end

function Lunge:GetCastRange()
	return self:GetSpecialValueFor("dash_range")
end

function Lunge:GetCastPoint()
	local cast_point = self.BaseClass.GetCastPoint(self)
	return cast_point
end


function Lunge:OnSpellStart()
	-- 防止鼠标点得太近技能卡住
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

	local caster = self:GetCaster()
	local ability = self
	local point = caster:GetCursorPosition()
	local sound_cast = "Hero_Pangolier.Swashbuckle.Cast"
	local modifier_movement = "Modifier_Lunge_Dash"
	local dash_range = ability:GetSpecialValueFor("dash_range")

	-- 转身
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)

	--播放动画和声音
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), sound_cast, caster)

	--开始位移
	caster:AddNewModifier(caster, ability, modifier_movement, {})

	--给修饰器传点击地点
	local modifier_movement_handler = caster:FindModifierByName(modifier_movement)
	modifier_movement_handler.target_point = point
end

