require( "boss/ai_core" )
-- 这里是创建一个新的变量，行为系统
behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
    -- 这个就是具体的AI循环的入口，返回的是behaviorSystem的Think函数
    thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    spawn_pos = thisEntity:GetAbsOrigin()
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorRunAway} ) 
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
	print(enemy)
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
		}
	end
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 0.4
end


--------------------------------------------------------------------------------------------------------


BehaviorRunAway = {}

function BehaviorRunAway:Evaluate()
		local desire = 0
        if currentBehavior == self then return desire end
        local pos = thisEntity:GetAbsOrigin()
        local distance = (pos - spawn_pos):Length2D()
        if distance > 800 then
            desire = 6
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
                        Position = spawn_pos
                })
end

BehaviorRunAway.Continue = BehaviorRunAway.Begin

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorRunAway }