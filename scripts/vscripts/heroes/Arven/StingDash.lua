StingDash = StingDash or class({})
LinkLuaModifier("Modifier_Lunge_Dash", "heroes/Arven/Modifier_Lunge_Dash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_Slashes", "heroes/Arven/Modifier_Lunge_Slashes.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Lunge_damage", "heroes/Arven/Modifier_Lunge_damage.lua", LUA_MODIFIER_MOTION_NONE)

--[[
function StingDash:GetAssociatedSecondaryAbilities()
	return ""
end
]]

function StingDash:GetManaCost(level)
	local manacost = self.BaseClass.GetManaCost(self, level)
	return manacost
end

function StingDash:GetCastRange()
	return self:GetSpecialValueFor("dash_range")
end

function StingDash:GetCastPoint()
	local cast_point = self.BaseClass.GetCastPoint(self)
	return cast_point
end


function StingDash:OnSpellStart()
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

