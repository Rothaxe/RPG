function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end


--[[哪里调用写在哪
fuction 调用的类名：xx函数（）
.
.
.
.
.
Timer(function()
	self.OnTimer()
	return x --@x:计时间隔
end)
.
.
.
.
.
.
end



--具体定义ontimer，
function 调用的类名：Ontimer（）

每次计时间隔做什么事情

end
]]

function ItemRollDrops(unit, owner)

    local DropInfo = GameRules.DropTable[unit]
    if DropInfo then
        for k,ItemTable in pairs(DropInfo) do
            local chance = ItemTable.Chance or 100
            local max_drops = ItemTable.Multiple or 1
            local item_name = ItemTable.Item
            for i=1,max_drops do -- 其他都是基本一样的，这里加个循环来多次掉落而已
                if RollPercentage(chance) then
                    print("Creating "..item_name)
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    local pos = owner:GetAbsOrigin()
                    local drop = CreateItemOnPositionSync( pos, item )
                    local pos_launch = pos+RandomVector(RandomFloat(0,0))
                    item:LaunchLoot(false, 500, 0.5, pos_launch) --(是否自动实用，高度，飞行时间，掉落位置)
                    item:GetContainer():SetModelScale(1)
                    item:GetContainer():SetForwardVector(RandomVector(400))
                    --local looteffect = ParticleManager:CreateParticle("particles/neutral_fx/neutral_item_drop.vpcf", PATTACH_WORLDORIGIN, item)
					--ParticleManager:SetParticleControl(looteffect, 0, item:GetAbsOrigin())
					--护甲模型models/items/dragon_knight/firedragon_shoulder/firedragon_shoulder.vmdl
					--武器模型models/heroes/phantom_assassin/weapon_fx.vmdl
					--宝箱models/props_gameplay/treasure_chest_gold.vmdl
					--凤凰蛋models/items/phoenix/ultimate/blazing_wing_blazing_egg/blazing_wing_blazing_egg.vmdl
					--莲花models/items/dark_willow/dark_willow_ti8_immortal_head/dark_willow_ti8_immortal_flower.vmdl
					--血石models/props_items/bloodstone.vmdl
					--A杖models/props_gameplay/aghanim_scepter.vmdl
					--戒指models/props_items/ring_health.vmdl
					--钱袋models/props_gameplay/gold_bag.vmdl
                end
            end
        end
    end
end


function DrawCards(unit)
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
        print("Rolling Drops for "..unit:GetUnitName())
        for k,ItemTable in pairs(DropInfo) do
            -- If its an ItemSet entry, decide which item to drop
            local item_name
            if ItemTable.ItemSets then
                -- Count how many there are to choose from
                local count = 0
                for i,v in pairs(ItemTable.ItemSets) do
                    count = count+1
                end
                local random_i = RandomInt(1,count)
                item_name = ItemTable.ItemSets[tostring(random_i)]
            else
                item_name = ItemTable.Item
            end
            local chance = ItemTable.Chance or 100
            local max_drops = ItemTable.Multiple or 1
            for i=1,max_drops do
                print("Rolling chance "..chance)
                if RollPercentage(chance) then
                    print("Creating "..item_name)
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    local pos = unit:GetAbsOrigin()
                    local drop = CreateItemOnPositionSync( pos, item )
                    local pos_launch = pos+RandomVector(RandomFloat(150,200))
                    item:LaunchLoot(false, 200, 0.75, pos_launch)
                end
            end
        end
    end
end


function Teleport(unit,postion,needCollision)
	if unit and postion then
		if needCollision then
			FindClearSpaceForUnit( unit, postion, true )
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=1})
		else
			FindClearSpaceForUnit( unit, postion, true ) --貌似最新版的只需要设置最后一个参数为true就能立刻触发触发区域的touch事件了。 先注释掉modifier，以后有变化了再说
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=1})
		end
	end
end




function GetNetTableValue(tableName,key)
	if type(tableName) == "string" and type(key) == "string" then
		return CustomNetTables:GetTableValue(tableName,key);
	end
end


function SetNetTableValue(tableName,key,valueTable)
	if type(tableName) == "string" and type(key) == "string" then
		CustomNetTables:SetTableValue(tableName,key,valueTable);
	end
end

function GetMaxAttr(caster)
    local str = caster:GetStrength()
    local agi = caster:GetAgility()
    local int = caster:GetIntellect()
    local maxattr = math.max(str, agi, int)
    return maxattr
end

function Jump(caster,target_location,speed,height,findPath,callback)
    local caster_location = caster:GetAbsOrigin()
    local fix_location = target_location
    local direction = (target_location - caster_location):Normalized()
    if findPath then
        if GridNav:CanFindPath(caster_location, target_location) == false then
            while(GridNav:CanFindPath(caster_location, fix_location) == false)
            do
                fix_location = fix_location - direction * 50
            end
            target_location = fix_location
        end
    end
    local distance = (target_location - caster:GetAbsOrigin()):Length2D()
    local height_fix = (caster_location.z - target_location.z) / distance
    local currentPos = Vector(0,0,0)
    speed = speed / 30
    local traveled_distance = 0
    Timers:CreateTimer(function ()
        if traveled_distance < distance then
            currentPos = caster:GetAbsOrigin() + direction * speed
            currentPos.z = caster_location.z + (-4 * height) / (distance ^ 2) * traveled_distance ^ 2 + (4 * height) / distance * traveled_distance - height_fix * traveled_distance
            caster:SetAbsOrigin(currentPos)
            traveled_distance = traveled_distance + speed
            return 0.01
        else--到达目标点
            --避免卡在某些场景里
            Teleport(caster,target_location,true)
            caster:Stop()--在服务器上如果不停止一下的话，单位会一直原地显示跑的动作
            if callback ~= nil then callback() end
        end
    end)
end



function swap(new, old, caster)
    --if not IsServer() then return end
    local newability = caster:FindAbilityByName(new)
    if newability == nil then
        newability = caster:AddAbility(new)
    end
    local level = caster:FindAbilityByName(old):GetLevel()
    newability:SetLevel(level)
    caster:SwapAbilities(new, old, true, false)
    --caster:RemoveAbility(old)
end




--伪随机
-- Rolls a Psuedo Random chance. If failed, chances increases, otherwise chances are reset
-- Numbers taken from https://gaming.stackexchange.com/a/290788
function RollPseudoRandom(base_chance, entity)
    local chances_table = {
        {1, 0.015604},
        {2, 0.062009},
        {3, 0.138618},
        {4, 0.244856},
        {5, 0.380166},
        {6, 0.544011},
        {7, 0.735871},
        {8, 0.955242},
        {9, 1.201637},
        {10, 1.474584},
        {11, 1.773627},
        {12, 2.098323},
        {13, 2.448241},
        {14, 2.822965},
        {15, 3.222091},
        {16, 3.645227},
        {17, 4.091991},
        {18, 4.562014},
        {19, 5.054934},
        {20, 5.570404},
        {21, 6.108083},
        {22, 6.667640},
        {23, 7.248754},
        {24, 7.851112},
        {25, 8.474409},
        {26, 9.118346},
        {27, 9.782638},
        {28, 10.467023},
        {29, 11.171176},
        {30, 11.894919},
        {31, 12.637932},
        {32, 13.400086},
        {33, 14.180520},
        {34, 14.981009},
        {35, 15.798310},
        {36, 16.632878},
        {37, 17.490924},
        {38, 18.362465},
        {39, 19.248596},
        {40, 20.154741},
        {41, 21.092003},
        {42, 22.036458},
        {43, 22.989868},
        {44, 23.954015},
        {45, 24.930700},
        {46, 25.987235},
        {47, 27.045294},
        {48, 28.100764},
        {49, 29.155227},
        {50, 30.210303},
        {51, 31.267664},
        {52, 32.329055},
        {53, 33.411996},
        {54, 34.736999},
        {55, 36.039785},
        {56, 37.321683},
        {57, 38.583961},
        {58, 39.827833},
        {59, 41.054464},
        {60, 42.264973},
        {61, 43.460445},
        {62, 44.641928},
        {63, 45.810444},
        {64, 46.966991},
        {65, 48.112548},
        {66, 49.248078},
        {67, 50.746269},
        {68, 52.941176},
        {69, 55.072464},
        {70, 57.142857},
        {71, 59.154930},
        {72, 61.111111},
        {73, 63.013699},
        {74, 64.864865},
        {75, 66.666667},
        {76, 68.421053},
        {77, 70.129870},
        {78, 71.794872},
        {79, 73.417722},
        {80, 75.000000},
        {81, 76.543210},
        {82, 78.048780},
        {83, 79.518072},
        {84, 80.952381},
        {85, 82.352941},
        {86, 83.720930},
        {87, 85.057471},
        {88, 86.363636},
        {89, 87.640449},
        {90, 88.888889},
        {91, 90.109890},
        {92, 91.304348},
        {93, 92.473118},
        {94, 93.617021},
        {95, 94.736842},
        {96, 95.833333},
        {97, 96.907216},
        {98, 97.959184},
        {99, 98.989899},    
        {100, 100}
    }

    entity.pseudoRandomModifier = entity.pseudoRandomModifier or 0
    local prngBase
    for i = 1, #chances_table do
        if base_chance == chances_table[i][1] then        
            prngBase = chances_table[i][2]
        end  
    end

    if not prngBase then
--      print("The chance was not found! Make sure to add it to the table or change the value.")
        return false
    end
    
    if RollPercentage( prngBase + entity.pseudoRandomModifier ) then
        entity.pseudoRandomModifier = 0
        return true
    else
        entity.pseudoRandomModifier = entity.pseudoRandomModifier + prngBase        
        return false
    end
end
