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