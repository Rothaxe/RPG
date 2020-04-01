LinkLuaModifier( "Modifier_Parry" , "heroes/Lauren/Modifier_Parry.lua" , LUA_MODIFIER_MOTION_NONE )
--require ('heroes/Lauren/Modifier_Parry')
require ('util/helperfunc')

function ApplyLuaModifier( keys )
    local caster = keys.caster
    local ability = keys.ability
    local modifiername = keys.ModifierName

    caster:AddNewModifier(caster, ability, modifiername, {})
end

function Active(keys)
	local caster = keys.caster
	local ability = keys.ability
	local parry_max_stacks= ability:GetSpecialValueFor("max_stacks")
	local duration = ability:GetSpecialValueFor("active_duration")

	caster:SetModifierStackCount("Modifier_Parry", caster, parry_max_stacks)
	Timer(duration, function()
		caster:SetModifierStackCount("Modifier_Parry", caster, 0)
	end)
	
--[[ 旧写法（备份）
	Modifier_Parry.active = 1
	Timer(0.2, function()
		Modifier_Parry.active = -1
		print(Modifier_Parry.active)
	end)
	print(Modifier_Parry.active)
	

	Timer(duration, function()
		Modifier_Parry.active = 0
		print(Modifier_Parry.active)
	end)
	Timer(duration + 0.2, function()
		Modifier_Parry.active = -1
		print(Modifier_Parry.active)
	end)
	]]
end	
