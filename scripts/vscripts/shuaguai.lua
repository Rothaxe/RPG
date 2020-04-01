--xiaoguai = {}
--wolfboss = {}

--[[function xiaoguai:createunit(unitname)
    local timeText = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeText))
    local deer = Entities:FindByName(nil, "deer")
    deer_loc = deer:GetAbsOrigin()

    --定位刷怪区域（左上和右下定位点中间区域随机位置刷鹿和狼）
    --local temp_zuoshang=Entities:FindByName(nil,"deer") --找到左上的定位点
    --zuoshang_zuobiao=temp_zuoshang:GetAbsOrigin()

    --local temp_youxia=Entities:FindByName(nil,"youxia") --找到左上的定位点
    --youxia_zuobiao=temp_youxia:GetAbsOrigin()   
    --local location = Vector(math.random(youxia_zuobiao.x - zuoshang_zuobiao.x)+zuoshang_zuobiao.x, math.random(youxia_zuobiao.y - zuoshang_zuobiao.y)+zuoshang_zuobiao.y,0)
    local unit = CreateUnitByName(unitname, deer_loc, true, nil, nil, DOTA_TEAM_BADGUYS)
    --local direction = Vector(math.random(-2000, 2000),math.random(-2000,2000),0)
    --print(direction)
    --local truedirection = location:Normalized()
    unit:FaceTowards(unit:GetAbsOrigin()+RandomVector(400))
    --unit:MoveToPosition(unit:GetAbsOrigin()+RandomVector(1000))
    unit:SetContext( "name", unitname, 0 )
end

function wolfboss:createunit(unitname)
    local WolfKing = Entities:FindByName(nil, "BOSS1")
    WolfKing_loc = WolfKing:GetAbsOrigin()
    local location = WolfKing_loc
    local unit = CreateUnitByName(unitname, location, true, nil, nil, DOTA_TEAM_BADGUYS)
    --local direction = Vector(math.random(-2000, 2000),math.random(-2000,2000),0)
    --print(direction)
    --local truedirection = location:Normalized()
    unit:FaceTowards(unit:GetAbsOrigin()+RandomVector(400))
    --unit:MoveToPosition(unit:GetAbsOrigin()+RandomVector(1000))
    unit:SetContext( "name", unitname, 0 )
end]]--

--[[function SpawnXiaoGuai(unitname)
    local SpawnInfo = GameRules.SpawnTable[unitname]
    if SpawnInfo then
        for unitname,EntityName in pairs(SpawnInfo) do

        local unit = CreateUnitByName(unitname, Entities:FindByName(nil, EntityName):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
        unit:FaceTowards(unit:GetAbsOrigin()+RandomVector(400))
        --unit:MoveToPosition(unit:GetAbsOrigin()+RandomVector(1000))
        unit:SetContext( "name", unitname, 0 )
        print(unitname)
        end
    end
end]]--


function StartShuaGuai()
    GroupSpawn()
end

--[[function SpawnXiaoGuai(unitname)
    local SpawnInfo  = GameRules.SpawnTable[unitname]
    if SpawnInfo then
        for unitname, EntityTable in pairs(SpawnInfo) do
            if EntityTable.locations then

                for i, EntityName in pairs(EntityTable.locations) do
                    local copyunit = CreateUnitByName(unitname, Entities:FindByName(nil, EntityName):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
                    print(Entities:FindByName(nil, EntityName):GetAbsOrigin())
                    print(unitname)
                end
                -- else
                --local uniqueunit = CreateUnitByName(unitname, Entities:FindByName(nil, EntityTable):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
            end 
        end
    end
end]]--


function GroupSpawn()
    local SpawnInfo  = GameRules.SpawnTable
    if SpawnInfo then
        for unitname, EntityTable in pairs(SpawnInfo) do
            if EntityTable.Waypoint then
                for i, EntityName in pairs(EntityTable.Waypoint) do
                    local Waypoint = Entities:FindByName(nil, EntityName)
                    local waypoint_vec = Entities:FindByName(nil, EntityName):GetAbsOrigin()
                    local groupunit = CreateUnitByName(unitname, waypoint_vec, true, nil, nil, DOTA_TEAM_BADGUYS)
                    --groupunit:FaceTowards(groupunit:GetAbsOrigin()+RandomVector(400))
                    groupunit:SetForwardVector(RandomVector(400))
                    groupunit:SetContext( "name", unitname, 0 )
                    groupunit:SetOwner(Waypoint)
                end
            end 
        end
    end
end

function RespawnGroupUnit(respawnname)
    local SpawnInfo  = GameRules.SpawnTable
    if SpawnInfo then
        for unitname, EntityTable in pairs(SpawnInfo) do
        	--if unitname == label then
            if EntityTable.Waypoint then
                for i, EntityName in pairs(EntityTable.Waypoint) do
                    local Waypoint = Entities:FindByName(nil, EntityName)
                    if EntityName == respawnname then
                    local groupunit = CreateUnitByName(unitname, Entities:FindByName(nil, EntityName):GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
                    --groupunit:FaceTowards(groupunit:GetAbsOrigin()+RandomVector(400))
                    groupunit:SetForwardVector(RandomVector(400))
                    groupunit:SetContext( "name", unitname, 0 )
                    groupunit:SetOwner(Waypoint)
                    --break
                    end
                end
            end 
        	--end
        end
    end
end