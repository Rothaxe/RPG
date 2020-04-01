--D技能 终极激光
UltimateLaser = class({})
require ('util/helperfunc')
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)

--[[function UltimateLaser:GetChannelTime()
	return 0.1
end]]--

function UltimateLaser:OnUpgrade()
	if IsServer() then
		self.laser = self:GetCaster():FindAbilityByName("UltimateLaser")
		self.EXlaser = self:GetCaster():FindAbilityByName("ExUltimateLaser")
		if  self.EXlaser == nil then
			self.EXlaser = self:GetCaster():AddAbility("ExUltimateLaser")
		end
		self.EXlaser:SetLevel(self.laser:GetLevel())
		self.EXlaser:StartCooldown(self.laser:GetCooldownTimeRemaining())
	end
end


function UltimateLaser:OnSpellStart()
	if IsServer() then
	self.jiguang = true
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	local start_pos = caster:GetAbsOrigin()

	local initalwidth = self:GetSpecialValueFor("initalwidth")
	local endwidth = self:GetSpecialValueFor("endwidth")
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance")

	local vDirection = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	local end_pos = start_pos + vDirection * 2000

	--靶心连线
	local laser_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/_3tinker_laser_b.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)	
	ParticleManager:SetParticleControl(laser_pfx, 1, Vector(end_pos.x,end_pos.y,start_pos.z))
	ParticleManager:SetParticleControl(laser_pfx, 9, Vector(start_pos.x,start_pos.y,start_pos.z))

	Timer(0,function()
	if self.jiguang == false then
	self.jiguang = true
	return
	end
	--瞄准特效
	self.aiming_pfx = ParticleManager:CreateParticle("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate_embers.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(self.aiming_pfx , 0, Vector(start_pos.x,start_pos.y,start_pos.z))
	return 0.3
	end)
	end
end


function UltimateLaser:OnChannelFinish(bInterrupted)
	if self.aming_pfx ~= nil then
	ParticleManager:DestroyParticle(self.aiming_pfx, false)
end
	if self.jiguang ~= nil then
	self.jiguang = false
end
	if bInterrupted then
			if self.EXlaser ~= nil then
			self.EXlaser:StartCooldown(self.laser:GetCooldownTimeRemaining())
			end
	return
else
	if IsServer() then
	--激光投射物
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
	local start_pos = caster:GetAbsOrigin()
	local initalwidth = self:GetSpecialValueFor("initalwidth")
	local endwidth = self:GetSpecialValueFor("endwidth")
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance")
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	local end_pos = start_pos + vDirection * 2000
	local laser_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/_2tinker_laser.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)	
		ParticleManager:SetParticleControl(laser_pfx, 0, start_pos)
		ParticleManager:SetParticleControl(laser_pfx, 1, Vector(end_pos.x,end_pos.y,start_pos.z+200))
		ParticleManager:SetParticleControl(laser_pfx, 3, start_pos)
		ParticleManager:SetParticleControl(laser_pfx, 9, Vector(start_pos.x,start_pos.y,start_pos.z+200))
		local info = {
		EffectName = laser_pfx,
		Ability = self,
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

				--后撤
			local backstep_loc = target_point
			knockback_properties = {
			 center_x 			= backstep_loc.x,
			 center_y 			= backstep_loc.y,
			 center_z 			= backstep_loc.z,
			 duration 			= 0.3,
			 knockback_duration = 1,
			 knockback_distance = 600,
			 knockback_height 	= 0,
			 should_stun = 0,
			 effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf",
			 attach_type = PATTACH_ABSORIGIN_FOLLOW
				}
			local knockback_modifier = caster:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)

				--概率刷新
		local success = RollPercentage(30)
		if success then 
		local success_pfx = ParticleManager:CreateParticle("particles/econ/events/ti8/hero_levelup_ti8_flash_hit_magic.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControl(success_pfx, 0, start_pos)
		self.laser:EndCooldown()
		else 
			if self.EXlaser ~= nil then
			self.EXlaser:StartCooldown(self.laser:GetCooldownTimeRemaining())
			end
		end
		end
	end
end

function UltimateLaser:OnProjectileHit(hTarget, vLocation)
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
	end
end

	--凤凰火特效
	--[[local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, nil )
	local attach_point = caster:ScriptLookupAttachment( "attach_hitloc" )

	ParticleManager:SetParticleControl( pfx, 0, caster:GetAttachmentOrigin(attach_point))

	ParticleManager:SetParticleControl( pfx, 1, target_point )]]--

	--TK激光
	--[[local laser_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)	
	ParticleManager:SetParticleControl(laser_pfx, 0, start_pos)
	ParticleManager:SetParticleControl(laser_pfx, 1, Vector(end_pos.x,end_pos.y,start_pos.z+200))
	ParticleManager:SetParticleControl(laser_pfx, 3, start_pos)
	ParticleManager:SetParticleControl(laser_pfx, 9, Vector(start_pos.x,start_pos.y,start_pos.z+200))]]--