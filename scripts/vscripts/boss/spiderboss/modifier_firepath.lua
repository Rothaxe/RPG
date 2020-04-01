modifier_firepath = class({})

function modifier_firepath:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_firepath:IsPurgable()	return false end
function modifier_firepath:RemoveOnDeath()	return false end

function modifier_firepath:OnCreated()
	if not IsServer() then return end
	
	self.damage_per_second	= self:GetAbility():GetSpecialValueFor("damage_per_second")
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")
	self.tick_interval		= self:GetAbility():GetSpecialValueFor("tick_interval")
	self.damage_type		= self:GetAbility():GetAbilityDamageType()
	print(self.damage_per_second)
	self.damage_table		= {
		victim 			= nil,
		damage 			= self.damage_per_second * self.tick_interval,
		damage_type		= self.damage_type,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	}
	
	-- Use these to track where and which enemies to be damaged
	self.damage_spots		= {}
	self.damaged_enemies	= {}
	
	self.think_interval		= 0.1
	self.counter			= 0
	-- Keep IntervalThink at 0.1 seconds (for damage spot drops + tree destruction), but change time_to_tick based on when it should do damage
	self.time_to_tick		= 0.1

	self.fire_debuff_particle	= nil
	
	if not self:GetAbility():GetAutoCastState() then
		self:GetParent():EmitSound("Hero_Batrider.Firefly.loop")
		
		self.ember_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.ember_particle, 11, Vector(1, 0, 0))
		self:AddParticle(self.ember_particle, false, false, -1, false, false)
		
		self.firefly_thinker = CreateModifierThinker(self:GetParent(), self:GetAbility(), "modifier_firepath_thinker", {duration = 4}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

		self:StartIntervalThink(self.think_interval)
	end
end

-- IntervalThink only starts once self.firefly_thinker exists (which handles flame drops)
function modifier_firepath:OnIntervalThink()
	self.counter	= self.counter + self.think_interval

	if self:GetParent():IsAlive() then
		table.insert(self.damage_spots, self:GetParent():GetAbsOrigin())
	end

	if self.counter >= self.time_to_tick then
		for damage_spot = 1, #self.damage_spots do
			self.enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.damage_spots[damage_spot], nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			
			for _, enemy in pairs(self.enemies) do
				if not self.damaged_enemies[enemy] then
					self.damage_table.victim = enemy
					
					self.fire_debuff_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
					ParticleManager:ReleaseParticleIndex(self.fire_debuff_particle)
					
					ApplyDamage(self.damage_table)
					self.damaged_enemies[enemy] = true
				end
			end
		end
		
		self.counter = 0
		-- Clear out damaged enemies table for next interval
		self.damaged_enemies = {}
	end

	-- "Deals 5/15/25/35 damage in 0.4 or 0.5 seconds intervals, starting 0.1 seconds after cast, the first interval is 0.4 seconds, the rest are 0.5 seconds, resulting in 31 (Talent 47) damage instances."
	if self:GetElapsedTime() < self.tick_interval then
		self.time_to_tick = 0.4
	else
		self.time_to_tick = 0.5
	end
end

function modifier_firepath:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return state
end

--------------------------------------------
-- modifier_firepath_THINKER --
--------------------------------------------
modifier_firepath_thinker = class({})
function modifier_firepath_thinker:IsPurgable()	return false end

-- "Minor" issue: Particles instantly vanish when modifier ends, unlike vanilla which has flames gradually vanish
-- function modifier_firepath_thinker:GetEffectName()
	-- return "particles/units/heroes/hero_batrider/batrider_firefly.vpcf"
-- end

function modifier_firepath_thinker:OnCreated()
	if not IsServer() then return end
	
	self.firefly_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	-- The immortal particle effect doesn't have CP11 set to (1, 0, 0) which basically ends up making the flames invisible, so I have to force it here
	ParticleManager:SetParticleControl(self.firefly_particle, 11, Vector(1, 0, 0))
	self:AddParticle(self.firefly_particle, false, false, -1, false, false)
	
	-- This seems better than a FrameTime() interval thinker to change origin? Wonder if there's any negative consequences...
	-- ...YEAH THE NEGATIVE CONSEQUENCE IS THE GOD DAMN INVIS = INVIS PARTICLES
	-- self:GetParent():FollowEntity(self:GetCaster(), false)
	
	self:StartIntervalThink(0.1)
end

function modifier_firepath_thinker:OnIntervalThink()
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
end

function modifier_firepath_thinker:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():RemoveSelf()
end