Effect_Lauren = Effect_Lauren or class({})
LinkLuaModifier("Modifier_Effect", "heroes/Lauren/Modifier_Effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Effect_Counter", "heroes/Lauren/Modifier_Effect_Counter.lua", LUA_MODIFIER_MOTION_NONE)

function Effect_Lauren:OnSpellStart()
	local caster = self:GetCaster()
	local count = caster:FindModifierByName("Modifier_Effect_Counter")
	count:IncrementStackCount()
	if count:GetStackCount() > 1 then 
		count:SetStackCount(0)
	end
end