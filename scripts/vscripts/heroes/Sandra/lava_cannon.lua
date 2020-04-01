--Q技能火焰榴弹
lava_cannon = class({})
require ('util/helperfunc')
LinkLuaModifier("modifier_energy_stack", "heroes/Sandra/modifier_energy_stack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Burn", "heroes/Modifier/modifier_Burn.lua", LUA_MODIFIER_MOTION_NONE)

function lava_cannon:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	self.start_loc= caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	-- Ability specials
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("damageradius")
	local damage = caster:GetAgility()*self:GetSpecialValueFor("multiple")
	self.distance = (self:GetCursorPosition() - self.start_loc):Length2D()
	local flytime = self.distance / speed

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


	--燃烧瓶
	local flamebreak_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(flamebreak_particle, 0, self:GetCaster():GetAbsOrigin() + Vector(0, 0, 200)) -- Arbitrary verticality increase
	ParticleManager:SetParticleControl(flamebreak_particle, 1, Vector(self:GetSpecialValueFor("speed")))
	ParticleManager:SetParticleControl(flamebreak_particle, 5, self:GetCursorPosition())


	--伤害
	Timer(flytime, function()
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		target_point,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)
		for _,enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = self:GetAbilityDamageType()})
		enemy:AddNewModifier(caster, ability, "modifier_Burn", {duration = self:GetSpecialValueFor("burnduration")})
		end
		ParticleManager:DestroyParticle(flamebreak_particle , true)
		self.pos = nil
	end)

	--投射物
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	local info = {
				--EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
				Ability = self,
				vSpawnOrigin = self:GetCaster():GetOrigin(), 
				fStartRadius = 100,
				fEndRadius = 100,
				vVelocity = vDirection * speed,
				fDistance = self.distance,
				Source = self:GetCaster(),
			}
		self.projID = ProjectileManager:CreateLinearProjectile( info )
	end

function lava_cannon:OnProjectileThink(vLocation)
	--算额外爆炸触发距离
	local traveled_distance = (vLocation - self.start_loc):Length2D()
	if traveled_distance  > self.distance*0.6 and traveled_distance < self.distance then
			if self.pos == nil then
			self.pos = vLocation
			end
			self.pos = vLocation
	end
end