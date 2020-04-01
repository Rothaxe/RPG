可以为所有的怪物设置一个通用的AI，让他们在移动超过开始地点的多少距离的时候，选择返回初始地点：

具体的是在创建单位的时候，为单位绑定一个初始地点：
local unit = CreateUnitByName(...)
unit.__spawnLocation = unit_origin
之后把他加入所有unit的全局table
table.insert(YourGameMode.__neutrals, unit)
之后在游戏的全局循环中调用：
function YourGameMode:Think()
    self:CheckNeutrals()    return 1
end

function YourGameMode:CheckNeutrals()
    for _, unit in pairs(self.__neutrals) do
        local distance = (unit:GetOrigin() - unit.__spawnLocation):Length2D()
        if distance > 3000 then
             unit:MoveToPosition(unit.__spawnLocation)
        end
    end
end