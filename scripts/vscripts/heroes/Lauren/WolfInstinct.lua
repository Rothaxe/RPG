WolfInstinct = class({})

LinkLuaModifier("Modifier_Move", "heroes/Lauren/Modifier_Move.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("Modifier_Rush", "heroes/Lauren/Modifier_Rush.lua", LUA_MODIFIER_MOTION_NONE)

function WolfInstinct:OnSpellStart()
	local caster = self:GetCaster()
	local caster_location = caster:GetAbsOrigin()
	local ability = self
	local distance = ability:GetSpecialValueFor("distance")
	local speed = ability:GetSpecialValueFor("speed")
	local move_modifier = caster:AddNewModifier(caster, self, "Modifier_Move",  {duration = distance / speed / 10 + 2})
	local modifier_movement_handler = caster:FindModifierByName("Modifier_Move")
	modifier_movement_handler.direction = caster:GetForwardVector()


	Timer(distance/speed/10, function()
		self.listener = ListenToGameEvent("entity_hurt", Dynamic_Wrap(WolfInstinct, "OnEntityHurt"), self)
		print(self.listener)
		Timer(2, function()
			if self.listener ~= nil then
				StopListeningToGameEvent(self.listener)
			end
		end)
	end)

end


function WolfInstinct:OnEntityHurt( keys )
	local killed = EntIndexToHScript(keys.entindex_killed)	
	
	if killed:GetName() == "npc_dota_hero_lina" then
		local attacker = EntIndexToHScript(keys.entindex_attacker)
		
		--if attacker:IsHero() then
			local caster = self:GetCaster()

			caster:RemoveModifierByName("Modifier_Move")
			
			local modifier = caster:AddNewModifier(caster, self, "Modifier_Rush", {duration = 3})
			modifier.target = attacker
			StopListeningToGameEvent(self.listener)
		--end
	end  
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