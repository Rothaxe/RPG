if modifier_energy_stack == nil then
	modifier_energy_stack = class({})
end


function modifier_energy_stack:IsPassive()
	return true
end

function modifier_energy_stack:IsPurgable() 
	return false
end

function modifier_energy_stack:IsHidden() 
	return false
end

function modifier_energy_stack:GetTexture()
	return "mirana_invis"
end

function modifier_energy_stack:OnCreated()
	if IsServer() then
		self:SetStackCount(0)
		self.laser = self:GetParent():FindAbilityByName("UltimateLaser")
		self.EXlaser = self:GetParent():FindAbilityByName("ExUltimateLaser")
		if  self.EXlaser == nil then
			self.EXlaser = self:GetParent():AddAbility("ExUltimateLaser")
			self.EXlaser:SetLevel(self.laser:GetLevel())
			self.EXlaser:StartCooldown(self.laser:GetCooldownTimeRemaining())
		end
		local halo_pfx = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light_halo_ring.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(halo_pfx, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_back", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(halo_pfx)
	end
end

function modifier_energy_stack:OnRefresh()
	--激光切换
	if self:GetStackCount() >= 5 then
		if self.EXlaser ~= nil  then
		self.laser:StartCooldown(self.EXlaser:GetCooldownTimeRemaining())
		self:GetParent():SwapAbilities("UltimateLaser", "ExUltimateLaser", false, true)
		end
	end
end
