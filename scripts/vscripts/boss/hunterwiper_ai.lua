require( "boss/ai_core" )
-- 这里是创建一个新的变量，行为系统
behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
    -- 这个就是具体的AI循环的入口，返回的是behaviorSystem的Think函数
    thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorCombo1, BehaviorCombo2, BehaviorCombo3,  BehaviorFanji, BehaviorRunAway} )
    --behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorCombo, BehaviorRunAway} ) 
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()       
end




--------------------------------------------------------------------------------------------------------
BehaviorNone = {}

function BehaviorNone:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 0.4

	local enemy = AICore:RandomEnemyHeroInRange(thisEntity, 800)
	if enemy and not thisEntity.dead then
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = enemy:GetOrigin()}
	else
		self.order =
		{
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = thisEntity:GetOwner():GetAbsOrigin()
		}
	end
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 0.4
end


--------------------------------------------------------------------------------------------------------
BehaviorCombo1 = {}

function BehaviorCombo1:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.combo1Ability = thisEntity:FindAbilityByName("BloodCry")
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemies > 0 and self.combo1Ability:IsFullyCastable() and not thisEntity.dead and thisEntity:GetHealth() <= thisEntity:GetMaxHealth() *0.8 then
		desire = 5
	end
	return desire
end

function BehaviorCombo1:Begin()
	local initial = thisEntity:SetAbsOrigin(thisEntity:GetOwner():GetAbsOrigin())
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.combo1Ability:entindex(),
	}
	ExecuteOrderFromTable(self.order)
end

BehaviorCombo1.Continue = BehaviorCombo1.Begin
------------------------------------------------------------------------------------------------------
BehaviorCombo2 = {}

function BehaviorCombo2:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.combo2Ability = thisEntity:FindAbilityByName("BloodCryKnockBack")
	local houjiao = thisEntity:FindAbilityByName("BloodCry")
	--local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if self.combo2Ability:IsFullyCastable() and not thisEntity.dead and (houjiao:GetCooldownTimeRemaining() - houjiao:GetCooldown(1)) >= -3 then
		desire = 4
	end
	return desire
end

function BehaviorCombo2:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.combo2Ability:entindex(),
	}
	ExecuteOrderFromTable(self.order)
end

BehaviorCombo2.Continue = BehaviorCombo2.Begin
------------------------------------------------------------------------------------------------------
BehaviorCombo3 = {}

function BehaviorCombo3:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.combo3Ability = thisEntity:FindAbilityByName("BloodCryDrag")
	local tuiren = thisEntity:FindAbilityByName("BloodCryKnockBack")
	--local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if self.combo3Ability:IsFullyCastable() and not thisEntity.dead and (tuiren:GetCooldownTimeRemaining() - tuiren:GetCooldown(1)) >= -3 then
		desire = 3
	end
	return desire
end

function BehaviorCombo3:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.combo3Ability:entindex(),
	}
	ExecuteOrderFromTable(self.order)
end

BehaviorCombo3.Continue = BehaviorCombo3.Begin
------------------------------------------------------------------------------------------------------
BehaviorFanji = {}

function BehaviorFanji:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.FanjiAbility = thisEntity:FindAbilityByName("WolfInstinct")
		if self.FanjiAbility:IsFullyCastable() and not thisEntity.dead and thisEntity:GetHealth() <= thisEntity:GetMaxHealth() *0.6 then
		desire = 8
		end
	return desire
end

function BehaviorFanji:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.FanjiAbility:entindex(),
	}
	ExecuteOrderFromTable(self.order)
end

BehaviorFanji.Continue = BehaviorFanji.Begin
------------------------------------------------------------------------------------------------------



BehaviorRunAway = {}

function BehaviorRunAway:Evaluate()
		waypoint  = thisEntity:GetOwner()
        local desire = 0
        if currentBehavior == self then return desire end
        local pos = thisEntity:GetAbsOrigin()
        local distance = (pos - waypoint:GetAbsOrigin()):Length2D()
        if distance > 1500 then
            desire = 7
        end 
        return desire
end


function BehaviorRunAway:Begin()
        self.endTime = GameRules:GetGameTime() + 6
end

function BehaviorRunAway:Think(dt)
                ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        Position = thisEntity:GetOwner():GetAbsOrigin()
                })
end

BehaviorRunAway.Continue = BehaviorRunAway.Begin

--------------------------------------------------------------------------------------------------------
--[[BehaviorCombo = {}

function BehaviorCombo:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.comboAbility1 = thisEntity:FindAbilityByName("BloodCry")
	self.comboAbility2 = thisEntity:FindAbilityByName("BloodCryKnockBack")
	self.comboAbility3 = thisEntity:FindAbilityByName("BloodCryDrag")
	local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemies > 0 and self.comboAbility1:IsFullyCastable() and not thisEntity.dead then
		desire = 7
	end
	return desire
end

function BehaviorCombo:Begin()
	local initial = thisEntity:SetAbsOrigin(thisEntity:GetOwner():GetAbsOrigin())
	local castcombo2 = false
	local castcombo3 = false
	self.endTime = GameRules:GetGameTime() + 1
	self.order1 =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.comboAbility1:entindex(),
	}
	castcombo2 = true
	print("combo1")
	ExecuteOrderFromTable(self.order1)

	if castcombo2 == true then
	self.order2 =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.comboAbility2:entindex(),
	}
	print("combo2")
	ExecuteOrderFromTable(self.order2)
	castcombo2 = false
	castcombo3 = true
	end

	if castcombo3 == true then
		self.order3 =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.comboAbility3:entindex(),
	}
	print("combo3")
	ExecuteOrderFromTable(self.order3)
	castcombo3 = false
	end
end
BehaviorCombo.Continue = BehaviorCombo.Begin]]--

------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = {  BehaviorNone, BehaviorCombo1, BehaviorCombo2, BehaviorCombo3, BehaviorFanji, BehaviorRunAway }