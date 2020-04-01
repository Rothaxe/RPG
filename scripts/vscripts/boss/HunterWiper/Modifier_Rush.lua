Modifier_Rush = class({})
require ('util/helperfunc')
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback.lua", LUA_MODIFIER_MOTION_NONE)
function Modifier_Rush:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
end

function Modifier_Rush:OnCreated()
	if IsServer() then
		self.caster = self:GetParent()
		self.ability = self:GetAbility()
		self.speed = self.ability:GetSpecialValueFor("speed") * FrameTime()
		self.vertical_speed = self.ability:GetSpecialValueFor("vertical_speed") * FrameTime()
		self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
		self.ground_point = self.caster:GetAbsOrigin().z
		Timer(FrameTime(),function()
			local target = self.target

			if target ~= nil then 
				self.target_pos = target:GetAbsOrigin()
				self.parent_loc = self.caster:GetAbsOrigin()
				self.distance = (self.target_pos - self.parent_loc):Length2D()

				--计算垂直速度
				--local height = self:GetAbility():GetSpecialValueFor("height")
				--local half_time = self.distance / 2 / self.speed
				--self.vertical_speed = height / half_time
				--开始飞扑
				self:StartIntervalThink(FrameTime())
			else 
				print("Error: nil target value")
			end
		end)
	end
end

function Modifier_Rush:OnIntervalThink()
	local caster = self.caster
	local direction = (self.target_pos - self.parent_loc):Normalized()

	--初始化
	if self.travel_distance == nil then
		self.travel_distance = 0
	end
	if self.vertical_pos == nil then 
		self.vertical_pos = self.parent_loc.z
	end

	--没到目标地点就持续位移
	if self.travel_distance < self.distance then
		local newPos = caster:GetAbsOrigin() + direction * self.speed

		--计算垂直坐标
		if self.travel_distance < self.distance / 2 then
			self.vertical_pos = self.vertical_pos + self.vertical_speed
			newPos.z = self.vertical_pos
			--print(newPos.z)
			--print(caster:GetOrigin().z)
		else
			self.vertical_pos = self.vertical_pos - self.vertical_speed
			newPos.z = self.vertical_pos
		end
		--修复z轴结束以后钻地（还是没好）
		if newPos.z < GetGroundHeight( caster:GetOrigin(), self:GetParent() ) then 
			newPos.z = GetGroundHeight( caster:GetOrigin(), self:GetParent() )
		end
		caster:SetOrigin(newPos)
		print(newPos)
		self.travel_distance = self.travel_distance + self.speed
	else
		caster:InterruptMotionControllers(true)

		--扑到目标地点重新判断距离，小于300过肩摔，否则直接return（飞扑被躲）
		--如果法爷做了相位转移，过肩摔判断需要加条件（坐标判断估计有bug）
		local parent_loc = self.caster:GetAbsOrigin()
		if (self.target:GetAbsOrigin() - parent_loc):Length2D() > 300 then
			self:GetParent():RemoveModifierByName("Modifier_Rush")
		else
			--local face_to = (self.target:GetAbsOrigin() - parent_loc)
			local distance = (self.target:GetAbsOrigin() - parent_loc):Length2D()
			--caster:SetForwardVector(face_to)

			damage = {
					victim = self.target,
					attacker = caster,
					damage = 300,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self.ability
				}
			ApplyDamage(damage)
			self.target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.2})

			--[[修复击退距离
			if distance < 200 then 
				distance = 200
			end
			]]
			
			Timer(0.2, function()
				knockback_properties = {
			 			center_x 			= parent_loc.x,
			 			center_y 			= parent_loc.y,
			 			center_z 			= parent_loc.z,
			 			duration 			= 0.2,
			 			knockback_duration = 0.2,
			 			knockback_distance = -distance - 400,
			 			knockback_height 	= 200,
			 			--should_stun = 1,
			 			effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
					}

				--播放动画并击退
				caster:StartGesture(ACT_DOTA_CAPTURE)
				self.target:AddNewModifier(caster, self, "modifier_custom_knockback", knockback_properties)
				caster:RemoveGesture(ACT_DOTA_CAPTURE)
				Timer(0.2, function()
					local drop = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, self.target)
					ParticleManager:SetParticleControl(drop, 0, self.target:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(drop)
					caster:MoveToTargetToAttack(self.target)
					
					self.target:AddNewModifier(caster, self, "modifier_stunned", {duration = self.stun_duration})
					caster:RemoveModifierByName("Modifier_Rush")
				end)
			end)
		end
		self:StartIntervalThink(-1)
	end
end

function Modifier_Rush:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return state
end


function Modifier_Rush:IsPurgable() 
	return false 
end

function Modifier_Rush:IsDebuff() 
	return false 
end

function Modifier_Rush:IsHidden()
	return true
end
