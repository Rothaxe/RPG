modifier_Flame_Torment = class({})

LinkLuaModifier("modifier_energy_stack", "heroes/Sandra/modifier_energy_stack.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_Flame_Torment:IsPassive()
	return true
end

function modifier_Flame_Torment:IsPurgable() 
	return false
end

function modifier_Flame_Torment:IsHidden() 
	return false
end

function modifier_Flame_Torment:OnCreated(keys)
	if IsServer() then
	local caster = self:GetParent()
	local target_point = self:GetAbility():GetCursorPosition()
	local start_pos = caster:GetAbsOrigin()

	local initalwidth = self:GetAbility():GetSpecialValueFor("initalwidth")
	local endwidth = self:GetAbility():GetSpecialValueFor("endwidth")
	local speed = self:GetAbility():GetSpecialValueFor("speed")
	local distance = self:GetAbility():GetSpecialValueFor("distance")
	
	--投射物1
	local vDirection = self:GetAbility():GetCursorPosition() - self:GetParent():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

		local info = {
		EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire_2.vpcf",
		Ability = self:GetAbility(),
		vSpawnOrigin = caster:GetOrigin(), 
		fStartRadius = initalwidth,
		fEndRadius = endwidth,
		vVelocity = vDirection * speed,
		fDistance = distance-endwidth,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					}	
		ProjectileManager:CreateLinearProjectile( info )

		--加层数
			local stack_modifier = caster:AddNewModifier(caster, self, "modifier_energy_stack", {})
			local old_stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
			local new_stack = old_stack + 1
			if new_stack >= 5 then
				new_stack = 5
			end
			caster:SetModifierStackCount("modifier_energy_stack", caster, new_stack)
			if new_stack == 5 then
			stack_modifier:ForceRefresh()
			end

		--计时
		self:StartIntervalThink(1)
	end
end

function modifier_Flame_Torment:OnIntervalThink()
		if IsServer() then
	local caster = self:GetParent()
	local target_point = self:GetAbility():GetCursorPosition()
	local start_pos = caster:GetAbsOrigin()
	local initalwidth = self:GetAbility():GetSpecialValueFor("initalwidth")
	local endwidth = self:GetAbility():GetSpecialValueFor("endwidth")
	local speed = self:GetAbility():GetSpecialValueFor("speed")
	local distance = self:GetAbility():GetSpecialValueFor("distance")

	--投射物2,3
	local vDirection = self:GetAbility():GetCursorPosition() - self:GetParent():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
		local info = {
		EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire_2.vpcf",
		Ability = self:GetAbility(),
		vSpawnOrigin = caster:GetOrigin(), 
		fStartRadius = initalwidth,
		fEndRadius = endwidth,
		vVelocity = vDirection * speed,
		fDistance = distance-endwidth,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					}	
		ProjectileManager:CreateLinearProjectile( info )

			--加层数
		local stack_modifier = caster:AddNewModifier(caster, self, "modifier_energy_stack", {})
		local old_stack = caster:GetModifierStackCount("modifier_energy_stack", caster)
		local new_stack = old_stack + 1
		if new_stack >= 5 then
		new_stack = 5
		end
		caster:SetModifierStackCount("modifier_energy_stack", caster, new_stack)
		if new_stack == 5 then
		stack_modifier:ForceRefresh()
		end

	end
end








































--[[function modifier_Flame_Torment:OnCreated(keys)
		if IsServer() then
				local caster = self:GetParent()
	local target_point = self:GetAbility():GetCursorPosition()

	local initalwidth = self:GetAbility():GetSpecialValueFor("initalwidth")
	local endwidth = self:GetAbility():GetSpecialValueFor("endwidth")
	local speed = self:GetAbility():GetSpecialValueFor("speed")
	local distance = self:GetAbility():GetSpecialValueFor("distance")

	local vDirection = self:GetAbility():GetCursorPosition() - self:GetParent():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

		local info = {
		EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
		Ability = self:GetAbility(),
		vSpawnOrigin = caster:GetOrigin(), 
		fStartRadius = initalwidth,
		fEndRadius = endwidth,
		vVelocity = vDirection * speed,
		fDistance = distance-endwidth,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					}	

		ProjectileManager:CreateLinearProjectile( info )
		self:StartIntervalThink(0.5)
	end
end

function modifier_Flame_Torment:OnIntervalThink()

	local caster = self:GetParent()
	local target_point = self:GetAbility():GetCursorPosition()

	local initalwidth = self:GetAbility():GetSpecialValueFor("initalwidth")
	local endwidth = self:GetAbility():GetSpecialValueFor("endwidth")
	local speed = self:GetAbility():GetSpecialValueFor("speed")
	local distance = self:GetAbility():GetSpecialValueFor("distance")

	local vDirection = self:GetAbility():GetCursorPosition() - self:GetParent():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

		local info = {
		EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
		Ability = self:GetAbility(),
		vSpawnOrigin = caster:GetOrigin(), 
		fStartRadius = initalwidth,
		fEndRadius = endwidth,
		vVelocity = vDirection * speed,
		fDistance = distance-endwidth,
		Source = caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					}	

		ProjectileManager:CreateLinearProjectile( info )
end]]--



	
	