Modifier_Effect_Counter = Modifier_Effect_Counter or class({})


function Modifier_Effect_Counter:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function Modifier_Effect_Counter:IsPassive()
	return true
end

function Modifier_Effect_Counter:IsPurgable() 
	return false
end
--[[ 
function Modifier_Effect_Counter:IsHidden() 
	return true 
end
]]

function Modifier_Effect_Counter:OnCreated()
	if IsServer() then
		self:SetStackCount(0)
		self:StartIntervalThink(0.1)
	end
end

function Modifier_Effect_Counter:OnIntervalThink()
	local caster = self:GetParent()
	local modifier = caster:FindModifierByName("Modifier_Effect")
	--print(modifier.blade)
	if self:GetStackCount() == 1 then 
		modifier.blade1 = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold_swipe_dark.vpcf"
		modifier.blade2 = "particles/econ/items/lifestealer/ls_ti9_immortal_gold/ls_ti9_open_wounds_gold_swipe.vpcf"
	end
	if self:GetStackCount() == 0 then 
		modifier.blade1 = "particles/econ/items/lifestealer/ls_ti9_immortal_gold/ls_ti9_open_wounds_gold_swipe.vpcf"
		modifier.blade2 = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift_gold_swipe_dark.vpcf"
	end
end