--2020.03.02
--如果法爷做了相位转移，反击飞扑需要加条件判断是否被躲，目前的坐标判断可能无效
--100%完成以后把ishero注释去掉
--TODO: 反击监视时候的红眼特效
--待修复：扑完以后会略微钻地(待观察，貌似是模型问题)
--2020.3.19
--在回跳之前先给自己加个魔免清BUFF，然后眩晕玩家2秒防止提前触发(暂时无效 无法清除已存在的燃烧DOT)
--调整后跳方向为出生点，距离也变为动态

WolfInstinct = class({})

LinkLuaModifier("Modifier_Move", "boss/HunterWiper/Modifier_Move.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Rush", "boss/HunterWiper/Modifier_Rush.lua", LUA_MODIFIER_MOTION_NONE)

function WolfInstinct:OnSpellStart()
	local caster = self:GetCaster()
	local caster_location = caster:GetAbsOrigin()
	local ability = self
	local distance = ability:GetSpecialValueFor("distance")
	local speed = ability:GetSpecialValueFor("speed")
	local counterattack_time = ability:GetSpecialValueFor("counterattack_time")
	local move_modifier = caster:AddNewModifier(caster, self, "Modifier_Move",  {duration = distance / speed / 10 + counterattack_time})
	local modifier_movement_handler = caster:FindModifierByName("Modifier_Move")
	--print(caster:GetOrigin())
	modifier_movement_handler.direction = (caster:GetAbsOrigin() - caster:GetOwner():GetAbsOrigin() ):Normalized()

	--先给自己加个短暂魔免，清掉身上debuff
	caster:AddNewModifier(caster, ability, "modifier_magic_immune", {duration = 1})

	--先群体眩晕2秒 再回到原点放见切，以防跳到一半就被触发反击
	local radius = self:GetSpecialValueFor("radius")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		local stun_modifier = enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = 1})
	end
		--特效
	local blast_pfx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(blast_pfx, 0, caster_location)
		ParticleManager:SetParticleControl(blast_pfx, 1, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(blast_pfx)
		EmitSoundOnLocationWithCaster( caster_location, "Ability.LightStrikeArray", caster )


	local delay = distance/speed/10 + 0.1
	Timer(delay, function()
		self.listener = ListenToGameEvent("entity_hurt", Dynamic_Wrap(WolfInstinct, "OnEntityHurt"), self)
		--紫罗兰之眼
		--local redeye = ParticleManager:CreateParticle("particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
					--ParticleManager:SetParticleControl(redeye, 0, self:GetCaster():GetAbsOrigin())
					--ParticleManager:ReleaseParticleIndex(redeye)
		--血裂			
		local redeye = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave_ground_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
					ParticleManager:SetParticleControl(redeye, 0, self:GetCaster():GetAbsOrigin())
					--ParticleManager:ReleaseParticleIndex(redeye)
		--变红
		self:GetCaster():SetRenderColor( 255, 0, 0) 
		--print(self.listener)
		Timer(counterattack_time, function()
			if self.listener ~= nil then
				StopListeningToGameEvent(self.listener)
				--去除红眼特效
				ParticleManager:DestroyParticle(redeye, true)
				--变回本色
				self:GetCaster():SetRenderColor( 255, 255, 255)
			end
		end)
	end)

end


function WolfInstinct:OnEntityHurt( keys )
		local attacker = EntIndexToHScript(keys.entindex_attacker)
		
		--if attacker:IsHero() then
			local caster = self:GetCaster()

			--caster:RemoveModifierByName("Modifier_Move")
			
			local modifier = caster:AddNewModifier(caster, self, "Modifier_Rush", {})
			modifier.target = attacker
			StopListeningToGameEvent(self.listener)
			--去除红眼特效
		--end
end

function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end