Modifier_Lunge_buff = Modifier_Lunge_buff or class({})

function Modifier_Lunge_buff:IsPurgable() 
	return false 
end

function Modifier_Lunge_buff:IsDebuff() 
	return false 
end

function Modifier_Lunge_buff:IsHidden()
	return true
end

function Modifier_Lunge_buff:GetEffectName()
	return "particles/econ/items/legion/legion_fallen/legion_fallen_press.vpcf"
end

function Modifier_Lunge_buff:OnCreated()
	if IsServer() then
		print("get buff!!")
	end
end
