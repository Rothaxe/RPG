--TODO：后续需要改为隐藏buff

if Counter_Allez == nil then
	Counter_Allez = class({})
end

function Counter_Allez:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function Counter_Allez:IsPassive()
	return true
end

function Counter_Allez:IsPurgable() 
	return false
end
 
function Counter_Allez:IsHidden() 
	return true 
end


function Counter_Allez:OnCreated()
	if IsServer() then
		self:SetStackCount(0)
	end
end

function Counter_Allez:DeclareFunctions() 
	return {
	MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function Counter_Allez:OnAttackStart(keys)
	local attack_times = self:GetAbility():GetSpecialValueFor("attack_times")
	if IsServer() then
		self:IncrementStackCount()
	end
end