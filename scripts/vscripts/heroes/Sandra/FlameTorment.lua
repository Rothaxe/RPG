--E技能火焰喷射器
FlameTorment = class({})
LinkLuaModifier("modifier_Flame_Torment", "heroes/Sandra/modifier_Flame_Torment.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_slow_debuff", "heroes/Modifier/modifier_slow_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function FlameTorment:OnSpellStart()
	local caster = self:GetCaster()
	local flame_modifier = caster:AddNewModifier(caster, self, "modifier_Flame_Torment",  {duration = 3})

	--周身特效
	self.surround_particle = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_buff_rear_fire.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(self.surround_particle, 1, caster:GetAbsOrigin())
end

function FlameTorment:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local damage = caster:GetAgility() * self:GetSpecialValueFor("multiple")
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
	local damagetable = {
		victim = hTarget,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self
		}
	ApplyDamage( damagetable )
	hTarget:AddNewModifier(caster, self, "modifier_slow_debuff", {duration = 3})
	end
end

function FlameTorment:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_Flame_Torment")
	ParticleManager:DestroyParticle(self.surround_particle,true)
end