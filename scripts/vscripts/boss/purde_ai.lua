-- 这边引入了我们主帖所说的AI核心
require( "ai_core" )
-- 这里是创建一个新的变量，行为系统
behaviorSystem = {} -- create the global so we can assign to it

-- 这个函数会在单位被创建的时候自动调用
-- 无论你这个单位是在地形编辑器里面创建并设置他的EntityScript
-- 还是使用的KV文件定义了他的vscript键值，再用Lua来刷出来
-- 都会调用这个函数
-- 刷一次调用一次这个文件，并自动执行这个函数
-- 同时把thisEntity这个变量赋值为那个具体的单位实体
function Spawn( entityKeyValues )

    -- 这个就是具体的AI循环的入口，返回的是behaviorSystem的Think函数
    thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )

    -- 之后是调用ai_core.lua函数中的CreateBehaviorSystem这个函数
    -- 也就是我们主帖所说的创建行为系统这一核心函数来为这个单位注册我们上面所说的四种行为
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorDismember, BehaviorThrowHook, BehaviorRunAway } ) 
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

-- 为了逃跑准备，从地图上收集一下逃跑的路径点，并付赋值给POSITIONS_retreat
function CollectRetreatMarkers()
        local result = {}
        local i = 1
        local wp = nil
        while true do
                -- 收集的是地图上名为
                -- waypoint_1，waypoint_2这样的地图实体
                wp = Entities:FindByName( nil, string.format("waypoint_%d", i ) )
                if not wp then
                        return result
                end
                table.insert( result, wp:GetOrigin() )
                i = i + 1
        end
end
POSITIONS_retreat = CollectRetreatMarkers()

--------------------------------------------------------------------------------------------------------
-- 这里是第一个行为，也就是攻击移动
BehaviorNone = {}

-- 默认的行动，他的评价函数就简单地返回一个最基础的数值，这样在核心函数的ChooseNextBehavior的时候，如果没有其他结果
-- 就会返回这个默认的行动
function BehaviorNone:Evaluate()
        return 1 -- must return a value > 0, so we have a default
end

-- 这个行动的具体函数
function BehaviorNone:Begin()
        self.endTime = GameRules:GetGameTime() + 1
        -- 查找一下敌方基地
        local ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )

        if ancient then
                -- 把具体的动作存入self.order中
                -- 并不需要做ExecuteOrderFromTable
                -- 因为核心函数会执行他的
                self.order =
                {
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                        Position = ancient:GetOrigin()
                }
        else
                -- 如果基地木有了，那就停止
                self.order =
                {
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_STOP
                }
        end
end

-- 继续执行的话，就简单地改变一下停止时间即可
function BehaviorNone:Continue()
        self.endTime = GameRules:GetGameTime() + 1
end

--------------------------------------------------------------------------------------------------------
-- 我们跳过这个技能，唯一需要注意的是，RandomEnemyHeroInRange这个函数
-- 是调用ai_core.lua文件中对应的函数
-- 在范围内随机找一个单位，仅此而已
BehaviorDismember = {}

function BehaviorDismember:Evaluate()
        self.dismemberAbility = thisEntity:FindAbilityByName("creature_dismember")
        local target
        local desire = 0

        -- let's not choose this twice in a row
        if AICore.currentBehavior == self then return desire end

        if self.dismemberAbility and self.dismemberAbility:IsFullyCastable() then
                local range = self.dismemberAbility:GetCastRange()
                target = AICore:RandomEnemyHeroInRange( thisEntity, range )
        end

        if target then
                desire = 5
                self.target = target
        else
                desire = 1
        end

        return desire
end

function BehaviorDismember:Begin()
        self.endTime = GameRules:GetGameTime() + 5

        self.order =
        {
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                UnitIndex = thisEntity:entindex(),
                TargetIndex = self.target:entindex(),
                AbilityIndex = self.dismemberAbility:entindex()
        }
end

-- 这里的Continue = Begin
-- 是为了说出现了某种情况
-- 比如说这个技能在释放的过程中被刷新（鬼知道为啥会出现这种情况）
-- 那么我们最好重复一下选择目标的动作
-- 否则简单执行一下延长施法时间就可以了
BehaviorDismember.Continue = BehaviorDismember.Begin

function BehaviorDismember:Think(dt)
        if not self.target:IsAlive() then
                self.endTime = GameRules:GetGameTime()
                return
        end
end

--------------------------------------------------------------------------------------------------------
-- 我们认真分析一下释放肉钩这个行为动作
--
BehaviorThrowHook = {}

-- 首先是评价函数
function BehaviorThrowHook:Evaluate()
        -- 首先初始化一下desire，设置为小于默认行为的值
        -- 这样在评价认为不适合释放肉钩的时候
        -- 能执行默认动作
        -- 
        local desire = 0

        -- 这一句话是为了避免说在肉钩已经被执行的情况下
        -- 重复地判断
        if currentBehavior == self then return desire end

        -- 获取肉钩这个技能的实体
        -- 用来判断当前技能的状态
        self.hookAbility = thisEntity:FindAbilityByName( "creature_meat_hook" )

        -- 确认技能获取正确     确认技能可以被释放
        if self.hookAbility and self.hookAbility:IsFullyCastable() then
                -- 确认技能的施法范围内有目标，如果有的话，那么赋予一个较大的值
                -- 4，小于释放肢解的5，这样在如果屠夫同时可以释放肉钩和肢解的情况下
                -- 屠夫会优先释放肢解
                -- 否则就释放肉钩
                -- 其实也可以加更复杂的判断
                -- 比如说加入对于敌方血量的判定
                -- 这就需要自己在做AI之前做好这个desire的表
                self.target = AICore:RandomEnemyHeroInRange( thisEntity, self.hookAbility:GetCastRange() )
                if self.target then
                        desire = 4
                end
        end

        -- 之后是更精确地判断一下是否适合释放肉钩
        --
        -- 首先是寻找一下400范围内的单位 
        local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
        if #enemies > 0 then
                -- 循环所有单位
                for _,enemy in pairs(enemies) do
                        -- 获取单位的方向
                        local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()
                        -- 获取屠夫自身的面向
                        local myForward = thisEntity:GetForwardVector()
                        -- 之后调用API函数计算一下这两个角之间的点积（不知道点积是啥的请百度）
                        local dotProduct = enemyVec:Dot( myForward ) 
                        -- 点积为正数，意味着这两个之间是锐角
                        if dotProduct > 0 then
                                -- 适当调低释放肉钩的意愿
                                desire = 2
                        end
                end
        end 
        -- 这个调整的意思是说
        -- 如果在我的面前的四百范围内
        -- 有敌方单位的话
        -- 屠夫就会相对比较不愿意释放肉钩了
        -- 如果在游戏的时候，就可以利用这一点……
        return desire
end

-- 下面这两个函数和上面的没啥区别
function BehaviorThrowHook:Begin()
        self.endTime = GameRules:GetGameTime() + 1

        local targetPoint = self.target:GetOrigin() + RandomVector( 100 )

        self.order =
        {
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                AbilityIndex = self.hookAbility:entindex(),
                Position = targetPoint
        }

end
BehaviorThrowHook.Continue = BehaviorThrowHook.Begin

--------------------------------------------------------------------------------------------------------
-- 这个是逃跑的函数
-- 也就是说，屠夫会根据身边700范围内的单位的数量来调整自身的选择
-- 700范围内的敌人数量越多
-- 那么逃跑的欲望就越大 desire = #enemies
-- 在逃跑的过程中，还会使用自身身上的推推拉，相位啦什么的
-- 这也就是为啥冥魂之夜在屠夫身边出现英雄之后
-- 屠夫就会开始进入一种不停运动的状态
-- 因为只有当身边的英雄数量 = 1的时候，RunAway的期望值才会和上面的None，也就是攻击移动的欲望值持平
-- 选择和你对砍
-- 而一旦身边出现了超过2名英雄
-- 就会随机选择一个目标地点开始移动
-- 直到可以释放肉钩或者肢解的时候
-- 才会停下来释放技能
-- 下面的这坨大家自己理解一下
BehaviorRunAway = {}

function BehaviorRunAway:Evaluate()
        local desire = 0
        local happyPlaceIndex =  RandomInt( 1, #POSITIONS_retreat )
        escapePoint = POSITIONS_retreat[ happyPlaceIndex ]
        -- let's not choose this twice in a row
        if currentBehavior == self then return desire end

        local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
        if #enemies > 0 then
                desire = #enemies
        end 

        for i=0,DOTA_ITEM_MAX-1 do
                local item = thisEntity:GetItemInSlot( i )
                if item and item:GetAbilityName() == "item_force_staff" then
                        self.forceAbility = item
                end
                if item and item:GetAbilityName() == "item_phase_boots" then
                        self.phaseAbility = item
                end
                if item and item:GetAbilityName() == "item_ancient_janggo" then
                        self.drumAbility = item
                end
                if item and item:GetAbilityName() == "item_urn_of_shadows" then
                        self.urnAbility = item
                end
        end

        return desire
end


function BehaviorRunAway:Begin()
        self.endTime = GameRules:GetGameTime() + 6

        self.order =
        {
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                UnitIndex = thisEntity:entindex(),
                TargetIndex = thisEntity:entindex(),
                AbilityIndex = self.forceAbility:entindex()
        }
end

function BehaviorRunAway:Think(dt)

        ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        TargetIndex = thisEntity:entindex(),
                        AbilityIndex = self.forceAbility:entindex()
                })

        if self.forceAbility and not self.forceAbility:IsFullyCastable() then
                ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        Position = escapePoint
                })
                ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                        AbilityIndex = self.drumAbility:entindex()
                })
                ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                        AbilityIndex = self.phaseAbility:entindex()
                })
        end

        if self.urnAbility and self.urnAbility:IsFullyCastable() and self.endTime < GameRules:GetGameTime() + 2 then
                ExecuteOrderFromTable({
                        UnitIndex = thisEntity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                        TargetIndex = thisEntity:entindex(),
                        AbilityIndex = self.urnAbility:entindex()
                })
        end
end

BehaviorRunAway.Continue = BehaviorRunAway.Begin

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorDismember, BehaviorThrowHook, BehaviorRunAway }