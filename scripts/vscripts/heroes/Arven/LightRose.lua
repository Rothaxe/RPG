LightRose = LightRose or class({})
LinkLuaModifier("modifier_judgement_debuff", "heroes/Arven/modifier_judgement_debuff.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function LightRose:OnUpgrade()
	local caster = self:GetCaster()
	caster:AddNewModifier(self:GetCaster(), self, "Counter_LightRose", {})

	self.LightRose_speed = self:GetSpecialValueFor( "LightRose_speed" )
	self.LightRose_width_initial = self:GetSpecialValueFor( "LightRose_width_initial" )
	self.LightRose_width_end = self:GetSpecialValueFor( "LightRose_width_end" )
	self.LightRose_distance = self:GetSpecialValueFor( "LightRose_distance" )
	self.LightRose_damage = self:GetSpecialValueFor( "LightRose_damage_multiple" ) * caster:GetAgility()
end

--------------------------------------------------------------------------------
function LightRose:OnSpellStart()

	EmitSoundOn( "Hero_Lina.DragonSlave.Cast", self:GetCaster() )

	local vPos = nil
	if self:GetCursorTarget() then
		vPos = self:GetCursorTarget():GetOrigin()
	else
		vPos = self:GetCursorPosition()
	end

	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	self.vDirection = vDirection

	local speed = self.LightRose_speed * ( self.LightRose_distance / ( self.LightRose_distance - self.LightRose_width_initial ) )
	--print(self.LightRose_speed)
	
	local info = {
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_2_terror.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.LightRose_width_initial,
		fEndRadius = self.LightRose_width_end,
		vVelocity = vDirection * speed,
		fDistance = self.LightRose_distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}

	self.projID = ProjectileManager:CreateLinearProjectile( info )
	EmitSoundOn( "Hero_Puck.Illusory_Orb_Damage", self:GetCaster() )
end

--------------------------------------------------------------------------------

function LightRose:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.LightRose_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_judgement_debuff", {duration = self:GetSpecialValueFor("Debuff_Duration")})

		--[[
		local vDirection = vLocation - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		]]
	end

	return false
end


