--TODO: 棋特效
PowerThrowing = PowerThrowing or class({})

require 'helper/helperfunc'
LinkLuaModifier("modifier_custom_knockback", "heroes/Modifier/modifier_custom_knockback", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flag_status", "heroes/Lanquan/flag_status.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flag_info", "heroes/Lanquan/flag_info.lua", LUA_MODIFIER_MOTION_NONE)

function PowerThrowing:OnUpgrade()
	--初始化旗子位置
	local caster = self:GetCaster()
	local pos = (Entities:FindByName(nil, "yincang")):GetOrigin()
	self.flag = CreateUnitByName("Qizhi", pos, true, caster, caster, caster:GetTeam())
	--不明原因导致上面创建时候设定的队伍无效，需要重新归队
	self.flag:SetTeam(caster:GetTeam())
	self.flag:SetOrigin(pos)
end
function PowerThrowing:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function PowerThrowing:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT
end


function PowerThrowing:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetCursorPosition()
	local range = self:GetSpecialValueFor("cast_range")
	local speed = self:GetSpecialValueFor("jump_speed")
	local particle_caster_ground = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf"
	--local particle_duel = "particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_ring_arcana.vpcf"
	local radius = self:GetSpecialValueFor("aoe_radius")
	local damage = self:GetSpecialValueFor("aoe_damage")*caster:GetStrength()
	local stun_time = self:GetSpecialValueFor("stun_time")
	local max_jump_height = self:GetSpecialValueFor("max_jump_height")
	local distance = (point - caster:GetAbsOrigin()):Length2D()

	--旗帜模型（只需要在这里改，其他技能会同步）
	local flag_model = "models/props_gameplay/ti9_consumable_banner.vmdl"

	if distance <= range then
		--如果是非法位置不作任何动作
		if GridNav:CanFindPath(caster:GetOrigin(), point) then
			--落旗
			local pos = {
				pos_x = point.x, 
				pos_y = point.y, 
				pos_z = point.z
			}
			self.flag:AddNewModifier(caster, self, "flag_info", pos)

			--落旗延迟 5000 / 500 = 10 帧 = 0.3s (见flag_info)
			Timer(0.3, function()

				--转移光环
				local aura = {"modifier_aura_red", "modifier_aura_regen", "modifier_aura_damage"}
				for i = 1, 3 do 
					local modifier = caster:FindModifierByName(aura[i])
					if modifier ~= nil then
						local ability = modifier:GetAbility()
						modifier:Destroy()
						self.flag:AddNewModifier(caster, ability, aura[i], {})
					end
				end

				--落旗特效+眩晕
				--local particle_duel_fx = ParticleManager:CreateParticle(particle_duel, PATTACH_ABSORIGIN, caster)
				--ParticleManager:SetParticleControl(particle_duel_fx, 0, point)
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, v in pairs(enemies) do
					if v ~= nil and ( not v:IsMagicImmune() ) and ( not v:IsInvulnerable() ) then
						v:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_time})
					end
				end
				--ParticleManager:DestroyParticle(particle_duel_fx, false)
			end)

			--显示无旗buff
			caster:AddNewModifier(caster, self, "flag_status", {flag_model = flag_model})

			--激活大招可释放状态
			local warcry = caster:FindAbilityByName("Warcry")
			if warcry:GetLevel() > 0 then 
				warcry:SetActivated(true)
			end

			--换技能
			swap("PowerThrowing_back", "PowerThrowing", caster)


			--触发狂暴之拳（插旗）,取消背旗被动
			local frenzy = caster:FindAbilityByName("FrenzyFist")
			if frenzy:GetLevel() > 0 then
				if caster:HasModifier("modifier_frenzy_beiqi") then
					caster:RemoveModifierByName("modifier_frenzy_beiqi")
				end
				caster:AddNewModifier(caster, frenzy, "modifier_frenzy", {})
			end

			--跳
			local jump_height = (distance / range) * max_jump_height
			local duration = distance / speed
			local info = {
				center_x 			= point.x,
				center_y 			= point.y,
				center_z 			= point.z,
				duration 			= duration + 0.2,
				knockback_duration = duration,
				knockback_distance = -distance,
				knockback_height 	= jump_height,
				xiangwei = 1,
				effect_name = "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf",
				attach_type = PATTACH_ABSORIGIN_FOLLOW
			}
			caster:AddNewModifier(caster, self, "modifier_custom_knockback", info)
		
			--落地伤害+特效
			Timer(duration + 0.1, function()
				enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, v in pairs(enemies) do
					if v ~= nil and ( not v:IsMagicImmune() ) and ( not v:IsInvulnerable() ) then
						local keys = {
							victim = v,
							attacker = caster,
							damage = damage,
							damage_type = DAMAGE_TYPE_MAGICAL,
							ability = self
						}
						ApplyDamage(keys)
					end
				end
				local particle_caster_ground_fx = ParticleManager:CreateParticle(particle_caster_ground, PATTACH_ABSORIGIN, caster)
				ParticleManager:SetParticleControl(particle_caster_ground_fx, 0, caster:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(particle_caster_ground_fx)
			end)
		end
	end
end



--------------------------------------------------------------------------------
--回到旗帜
PowerThrowing_back = PowerThrowing_back or class({})

function PowerThrowing_back:OnUpgrade()
	local flag = self:GetCaster():FindModifierByName("flag_status")
	local model =  flag.flag_model
	self.flag = Entities:FindByModel(nil, model)
end

function PowerThrowing_back:OnOwnerSpawned()
	local caster = self:GetCaster()
	if self:GetAbilityIndex() == 1 then
		swap("PowerThrowing", "PowerThrowing_back", caster)
	end
end

--死亡以后切换技能以及换回背旗状态
function PowerThrowing_back:OnOwnerDied()
	local caster = self:GetCaster()
	removeFlag(self.flag)
	--swap("PowerThrowing", "PowerThrowing_back", caster)
end

function PowerThrowing_back:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self.flag:GetOrigin()
	local distance = (pos - caster:GetOrigin()):Length2D()
	local aura_radius = self:GetSpecialValueFor("jianqi_range")

	--瞬移（在光环里就可以瞬移回去）
	if distance <= aura_radius then
		FindClearSpaceForUnit(caster, pos, true)
	end

	--转移光环
	local aura = {"modifier_aura_red", "modifier_aura_regen", "modifier_aura_damage"}
	for i = 1, 3 do 
		local modifier = self.flag:FindModifierByName(aura[i])
		if modifier ~= nil then
			local ability = modifier:GetAbility()
			modifier:Destroy()
			caster:AddNewModifier(caster, ability, aura[i], {})
		end
	end

	--更新背旗状态
	caster:RemoveModifierByName("flag_status")

	--取消大招
	local warcry = caster:FindAbilityByName("Warcry")
	if caster:HasModifier("modifier_warcry") then
		caster:RemoveModifierByName("modifier_warcry")
	end
	warcry:SetActivated(false)


	--去除旗帜
	removeFlag(self.flag)

	swap("PowerThrowing", "PowerThrowing_back", caster)

	--去除狂暴之拳(插旗)，触发背旗被动
	local frenzy = caster:FindAbilityByName("FrenzyFist")
	if frenzy:GetLevel() > 0 then
		if caster:HasModifier("modifier_frenzy") then
			caster:RemoveModifierByName("modifier_frenzy")
		end
		caster:AddNewModifier(caster, frenzy, "modifier_frenzy_beiqi", {})
	end

	
end

function removeFlag(flag)
	local pos = flag:GetOrigin() + Vector(5200, 5200, -500)
	flag:SetOrigin(pos)
	flag:ForceKill(false)
end