--2020.02.15 1，开局要先放一下主动，才能正常触发普攻自动放技能（可修复，太麻烦暂时不管，影响很小）
--2020.02.17 2，刺中球炸出aoe还需进一步检验是否存在bug
Allez = Allez or class({})
LinkLuaModifier("Counter_Allez", "heroes/Lauren/Counter_Allez.lua", LUA_MODIFIER_MOTION_NONE)
require ('helper/helperfunc')

--------------------------------------------------------------------------------
function Allez:OnUpgrade()
	local caster = self:GetCaster()
	caster:AddNewModifier(self:GetCaster(), self, "Counter_Allez", {})

	self.Allez_speed = self:GetSpecialValueFor( "Allez_speed" )
	self.Allez_width_initial = self:GetSpecialValueFor( "Allez_width_initial" )
	self.Allez_width_end = self:GetSpecialValueFor( "Allez_width_end" )
	self.Allez_distance = self:GetSpecialValueFor( "Allez_distance" )
	self.Allez_damage = self:GetSpecialValueFor( "Allez_damage" ) 
end

--------------------------------------------------------------------------------
function Allez:OnSpellStart()

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

	local speed = self.Allez_speed * ( self.Allez_distance / ( self.Allez_distance - self.Allez_width_initial ) )
	--print(self.Allez_speed)
	
	local info = {
		EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.Allez_width_initial,
		fEndRadius = self.Allez_width_end,
		vVelocity = vDirection * speed,
		fDistance = self.Allez_distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}

	self.projID = ProjectileManager:CreateLinearProjectile( info )

	
	--打满x下自动放技能
	Timer(function()
		local caster = self:GetCaster()
		local stacks = self:GetCaster():GetModifierStackCount("Counter_Allez", caster)
		local attack_times = self:GetSpecialValueFor("attack_times")
		if stacks >= attack_times then 
			local vSpawnOrigin = caster:GetOrigin()
			local vForward = caster:GetForwardVector()
			local vDirection = vForward:Normalized()
			local speed = self.Allez_speed * ( self.Allez_distance / ( self.Allez_distance - self.Allez_width_initial ) )
			print(vForward)
			print(vDirection)
			local info = {
				EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
				Ability = self,
				vSpawnOrigin = self:GetCaster():GetOrigin(), 
				fStartRadius = self.Allez_width_initial,
				fEndRadius = self.Allez_width_end,
				vVelocity = vDirection * speed,
				fDistance = self.Allez_distance,
				Source = self:GetCaster(),
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			}
			ProjectileManager:CreateLinearProjectile( info )
			self:GetCaster():SetModifierStackCount("Counter_Allez", self:GetCaster(), 0)
		end
		return 0.1 
	end)



	EmitSoundOn( "Hero_Puck.Illusory_Orb_Damage", self:GetCaster() )
end

--------------------------------------------------------------------------------

function Allez:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.Allez_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )

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

--------------------------------------------------------------------------------
function Allez:OnProjectileThink(vLocation)
	local caster = self:GetCaster()
	if IsServer() then
		local modifier = caster:FindModifierByName("Modifier_Lunge_Slashes")
		if modifier ~= nil then
			local range = modifier.range
			local points = {
				end_point = caster:GetAbsOrigin() + caster:GetForwardVector() * range,
				three_quarter = caster:GetAbsOrigin() + caster:GetForwardVector() * range * 0.75,
				mid_point = caster:GetAbsOrigin() + caster:GetForwardVector() * range * 0.5,
				quarter_point = caster:GetAbsOrigin() + caster:GetForwardVector() * range * 0.25
			}
			for _, v in pairs(points) do
				--print(v)
				local distance = (v - vLocation):Length2D()
				if distance <= self.Allez_width_initial then
					local ability = caster:FindAbilityByName("Lunge")
					
					--加血
					local heal_amount = ability:GetSpecialValueFor("heal_amount")
					caster:Heal(heal_amount, caster)

					--炸和上buff
					caster:AddNewModifier(caster, ability, "Modifier_Lunge_buff", {duration = modifier:GetAbility():GetSpecialValueFor("buff_duration")})
					caster:AddNewModifier(caster, ability, "Modifier_Lunge_explosion", {})
					ProjectileManager:DestroyLinearProjectile(self.projID)
					caster:RemoveModifierByName("Modifier_Lunge_explosion")
					break
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
