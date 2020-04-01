modifier_random_scale = class({})


function modifier_random_scale:IsPurgable() 
	return false
end

function modifier_random_scale:IsDebuff() 
	return false 
end

function modifier_random_scale:IsHidden()
	return true
end

function modifier_random_scale:OnCreated(keys)
	if IsServer() then
		local randomscale = self:GetParent():SetModelScale((self:GetParent():GetModelScale())*RandomFloat(0.8, 1.2))
	end
end


