modifier_attack_passive = class({})
LinkLuaModifier("modifier_energy_stack", "heroes/Sandra/modifier_energy_stack.lua", LUA_MODIFIER_MOTION_NONE)

if modifier_attack_passive == nil then
	modifier_attack_passive = class({})
end


function modifier_attack_passive:IsPassive()
	return true
end

function modifier_attack_passive:IsPurgable() 
	return false
end

function modifier_attack_passive:IsHidden() 
	return false
end

function modifier_attack_passive:GetTexture()
	return "mirana_invis"
end


function modifier_attack_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_attack_passive:OnAttackLanded(event)
    if IsServer() then
    	if RollPercentage(50) then
    		local caster = self:GetParent()
    		local stack_modifier = caster:AddNewModifier(caster, self, "modifier_energy_stack", {})
			local old_stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
			local new_stack = old_stack + 1
			if new_stack >= 5 then
			new_stack = 5
			end
			caster:SetModifierStackCount("modifier_energy_stack", caster, new_stack)
			print("success!!!")
			if new_stack == 5 then
			stack_modifier:ForceRefresh()
			end
		end
	end       
end