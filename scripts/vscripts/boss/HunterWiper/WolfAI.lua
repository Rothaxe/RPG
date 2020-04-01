--[[
	- A simple AI script example for the Troll Summoner boss in Adventure Example that allows him to cast abilities
	- This is not designed to be applied to any unit with abilities and is rather specific to this addon
	- The npc does not act like a neutral and will pursue heroes for infinite distance, additional script would need to control
		this behavior
]]

-- Store all the ability names in a table on the entity running this script
thisEntity.activeAbilities = {}



-- When the unit spawns into the world, setup the thinker
function Spawn( entityKeyValues )
	SetUpAIThink()
end


function SetUpAIThink()
	thisEntity:SetContextThink( "AIThink", AIThink, 0.5 )
	GetAbilities()
end


-- Main think function for this unit
function AIThink()
	if thisEntity:IsAlive() ~= true then
		return nil
	end

	-- If the unit is attacking something GetAttackTarget() will return the target which is passed into CastAbilities( target )
	if thisEntity:GetAttackTarget() ~= nil then
		CastAbilities( thisEntity:GetAttackTarget() )
	end

	return 0.5
end

-- Attempt to cast any abilities that are on the unit
function CastAbilities( target )
	local abilityName = thisEntity.activeAbilities[ RandomInt( 1, #thisEntity.activeAbilities ) ]
	local ability = thisEntity:FindAbilityByName( abilityName )

	-- If the ability is being channelled exit the function
	if ability:IsChanneling() then
		return
	end

	-- Check mana requirements
	if ability:IsOwnersManaEnough() == false then
		return
	end

	-- Which ability is being cast?  Each one requires a different type of function call (target versus no target in this example)
	if abilityName == "BloodCry" then
		thisEntity:CastAbility( ability, -1 )
	end
end


-- Find all the active abilities on this unit and build a list (assumes active abilities exist, this is not a robust solution for various npcs)
function GetAbilities()
	if thisEntity:GetAbilityCount() == 0 then
		print( "no abilities")
		return
	end

	local nAbilitiesIndex = 1

	--print( thisEntity:GetAbilityCount() )

	for i = 0, thisEntity:GetAbilityCount()-1 do
		local ability = thisEntity:GetAbilityByIndex( i ) -- set this to minus one once jeff's changes are through to test the code fix
		
		if ability ~= nil then
			local nBehaviorFlags = ability:GetBehavior()

			if DOTA_ABILITY_BEHAVIOR_HIDDEN ~= bit.band( DOTA_ABILITY_BEHAVIOR_HIDDEN, nBehaviorFlags ) and DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE ~= bit.band( DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE, nBehaviorFlags ) and ability:GetAbilityName() ~= "attribute_bonus" then
				thisEntity.activeAbilities[nAbilitiesIndex] = ability:GetAbilityName()
				nAbilitiesIndex = nAbilitiesIndex + 1
			end
		end
	end
end