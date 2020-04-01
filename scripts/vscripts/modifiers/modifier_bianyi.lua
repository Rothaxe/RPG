modifier_bianyi = class({})
LinkLuaModifier("modifier_fast_buff_bianyi", "modifiers/modifier_fast_buff_bianyi.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_bianyi
:IsPurgable() 
	return false
end

function modifier_bianyi
:IsDebuff() 
	return false 
end

function modifier_bianyi
:IsHidden()
	return true
end

function modifier_bianyi
:OnCreated(keys)
	if IsServer() then
		local unit = self:GetParent()
		local randomscale = unit:SetModelScale(unit:GetModelScale()*2)
		local bianyiyanse = unit:SetRenderColor(135,206,250) 
		local initialhp = unit:GetBaseMaxHealth()
		--[[if initialhp then
		local bianyimaxhp = unit:SetBaseMaxHealth(initialhp*1.5)
		end
		if bianyimaxhp then
			unit:SetBaseMaxHealth(bianyimaxhp)
		end]]--
		local bianyimaxhp = unit:SetBaseMaxHealth(initialhp * 1.5)
		local bianyigongjimin = unit:SetBaseDamageMin(unit:GetBaseDamageMin()*1.5)
		local bianyigongjimax = unit:SetBaseDamageMax(unit:GetBaseDamageMax()*1.5)
		local bianyiarmor = unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorBaseValue()*1.5)
		local bianyigongsu = unit:AddNewModifier(unit, nil, "modifier_fast_buff_bianyi", {})
		unit:SetContext( "bianyi", "bianyied", 0 )
	end
end


