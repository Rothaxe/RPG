function StartShuaGuai()
    local timeText = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeText))
    --定位刷怪区域（左上和右下定位点中间区域随机位置刷鹿和狼）
    local temp_zuoshang=Entities:FindByName(nil,"zuoshang") --找到左上的定位点
    zuoshang_zuobiao=temp_zuoshang:GetAbsOrigin()

    local temp_youxia=Entities:FindByName(nil,"youxia") --找到左上的定位点
    youxia_zuobiao=temp_youxia:GetAbsOrigin()   
 
    createunit("redwolf")
    createunit("redwolf")
    createunit("redwolf")
    createunit("redwolf")
    createunit("redwolf")

    createunit("Axe")
    createunit("Axe")
end

function createunit(unitname)
    local location = Vector(math.random(youxia_zuobiao.x - zuoshang_zuobiao.x)+zuoshang_zuobiao.x, math.random(youxia_zuobiao.y - zuoshang_zuobiao.y)+zuoshang_zuobiao.y,0)
    local unit = CreateUnitByName(unitname, location, true, nil, nil, DOTA_TEAM_BADGUYS)
    --local direction = Vector(math.random(-2000, 2000),math.random(-2000,2000),0)
    --print(direction)
    --local truedirection = location:Normalized()
    unit:FaceTowards(unit:GetAbsOrigin()+RandomVector(400))
    --unit:MoveToPosition(unit:GetAbsOrigin()+RandomVector(1000))
    unit:SetContext( "name", unitname, 0 )
end

