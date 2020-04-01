if modifier_truegold == nil then
	modifier_truegold = class({})
end

function modifier_truegold:RemoveOnDeath()
	return false
end

function modifier_truegold:IsPassive()
	return true
end

function modifier_truegold:IsPurgable() 
	return false
end

function modifier_truegold:IsHidden() 
	return false
end

function modifier_truegold:GetTexture()
	return "item_keeper_of_the_light_illuminate"
end

function modifier_truegold:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end