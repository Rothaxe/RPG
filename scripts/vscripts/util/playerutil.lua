---玩家数据
--key是玩家id，value是一个table，包括各个玩家的数据
local PlayerData = {}
---玩家总数，无论是否在线，只要完全连入过游戏，就算一个
local PlayerCount = 0;


local m = {}

---记录一个玩家信息。如果PlayerID不空，则添加一个玩家，会增加玩家数量。
--<p>如果hero为空，则不初始化玩家相关属性
function m.addPlayer(PlayerID,hero)
	if PlayerID then
		if PlayerData[PlayerID] == nil then
			PlayerData[PlayerID] = {}
			PlayerCount = PlayerCount + 1
		end
		
		if hero then
			m.SetHero(PlayerID,hero)
		end
	end
end

---设置一个玩家的英雄实体，同时根据英雄单位，初始化玩家的相应属性
function m.SetHero(PlayerID,hero)
	if PlayerID and hero and PlayerData[PlayerID] then
		local player = PlayerData[PlayerID]
		--缓存英雄实体的索引，当玩家断开连接后，通过玩家id将获取不到玩家，也就不能获取其控制的英雄，会出现各种bug
		--所以统一修改为用本身缓存的去获得
		player._Hero = hero;
		--记录该单位拥有的所有单位
		local units = {hero,courier}
		player._Units = units
		
		--背包，在单位都初始化完毕以后
		Backpack.initBackpack(PlayerID)
	end
end

-- 根据玩家id获取对应的英雄实体(如果有的话)<p>
-- @param playerID 玩家id

---根据玩家信息获取对应的英雄实体。
--@param #any player 玩家id或者玩家所拥有的单位实体
function m.GetHero(player)
	--从缓存中读取英雄
	return  m.getAttrByPlayer(player,"_Hero")
end

---获取指定玩家拥有的所有单位，返回一个数组
function m.GetPlayerUnits(player)
	return m.getAttrByPlayer(player,"_Units")
end

---根据玩家id或者玩家拥有的实体，获取玩家实体。
--@param #any playerID 玩家id
--@param #boolean allState 是否返回所有状态的玩家，默认只返回连入游戏的玩家
function m.GetPlayer(playerID,allState)
	if type(playerID) == "table" then
		playerID = playerID:GetPlayerOwnerID()
	end
	--先获取玩家状态： 0 - 无连接. 1 - 机器人连入. 2 - 玩家连入. 3 机器人/玩家断线. 如果玩家断开则返回nil
	if PlayerResource:GetConnectionState(playerID) == 2 or allState then
		return PlayerResource:GetPlayer(playerID);
	end
end

---根据单位实体返回该单位所属的玩家id
function m.GetOwnerID(unit)
	if type(unit) == "table" then
		return unit:GetPlayerOwnerID()
	end
end

---获取所有玩家的id，无论是否在线
--返回一个数组
--@param #boolean noDisconnect 忽略不在线的玩家
function m.GetAllPlayersID(noDisconnect)
	local result = {}
	for playerID, data in pairs(PlayerData) do
		if type(playerID) == "number" then
			if noDisconnect then
				if PlayerResource:GetConnectionState(playerID) == 2 then
					table.insert(result,playerID)
				end
			else
				table.insert(result,playerID)
			end
		end
	end
	return result;
end

---获取当前进入游戏的玩家数量
--@param #boolean noDisconnect 忽略不在线的玩家
function m.GetPlayerCount(noDisconnect)
	if noDisconnect then
		local count = 0
		for playerID, data in pairs(PlayerData) do
			if type(playerID) == "number" then
				if noDisconnect then
					if PlayerResource:GetConnectionState(playerID) == 2 then
						count = count + 1
					end
				else
					count = count + 1
				end
			end
		end
		
		return count
	else
		return PlayerCount
	end
end


---获取玩家的某项属性。参数为空或者找不到，则返回nil
--@param #any player 玩家id或者单位实体
--@param #string attrName 属性标识，不可为空
function m.getAttrByPlayer(player,attrName)
	if player and attrName and PlayerData then
		local data = PlayerData[player]
		if data then
			return data[attrName]
		end
	end
end

---设置玩家的属性
--@param #any player 玩家id或者单位实体。默认只有初始化过英雄的玩家才会有缓存数据，如果不存在缓存数据，则不会存储当前数据。
--@param #string attrName 属性标识，不可为空
--@param #any value 属性值，可为空
function m.setAttrByPlayer(player,attrName,value)
	if player and attrName and PlayerData then
		if type(player) == "table" then
			player = m.GetOwnerID(player)
		end
		local data = PlayerData[player]
		if data then
			data[attrName] = value
		end
	end
end

---增加指定玩家的大三维：经脉、灵力、内息
--@param #any player 玩家id或者玩家所拥有的单位实体
--@param #number amount 增加的数值，可正可负。为0不处理
function m.AddBig3(player,amount)
	if type(amount) ~= "number" or amount == 0 then
		return;
	end
	
	local hero = m.GetHero(player)
	if hero then
		CAS.AddAttribute(hero,CA.JingMai,amount)
		CAS.AddAttribute(hero,CA.NeiXi,amount)
		CAS.AddAttribute(hero,CA.LingLi,amount)
	end	
end

---增加某个玩家的金币
--@param #any player 玩家id或者玩家所拥有的单位实体
--@param #number gold 要修改的金币数量，必须大于0
function m.AddGold(player,gold)
	if player and type(gold) == "number" and gold > 0 then
		if type(player) == "table" then
			player = m.GetOwnerID(player)
		end
		
		if type(player) == "number" then
			PlayerResource:ModifyGold(player,gold,true,DOTA_ModifyGold_Unspecified)
		end
	end
end

---消耗某个玩家的金币。<p>
--使用modify的话，需要指明是否是可靠金钱，会导致扣钱的时候不能扣除足够的金币。
--所以用这个Spend单独处理金币减少的逻辑
--@param #any player 玩家id或者玩家所拥有的单位实体
--@param #number gold 要修改的金币数量，必须大于0
function m.SpendGold(player,gold)
	if player and type(gold) == "number" and gold > 0 then
		if type(player) == "table" then
			player = m.GetOwnerID(player)
		end
		
		if type(player) == "number" then
			PlayerResource:SpendGold(player,gold,DOTA_ModifyGold_Unspecified)
		end
	end
end

--记录指定玩家当前使用的宠物
function m.SetPet(playerID,pet)
	m.setAttrByPlayer(playerID,"_Pet",pet)
end

--获取玩家当前使用的宠物。
function m.GetPet(playerID)
	return m.getAttrByPlayer(playerID,"_Pet");
end

--移除玩家当前使用的宠物。并删掉宠物实体
function m.RemovePet(playerID)
	local pet = m.GetPet(playerID);
	if pet ~= nil then
		--如果存在宠物，则删除之前的宠物
		pet:RemoveSelf();
		m.setAttrByPlayer(playerID,"_Pet",nil);
	end
end

---获取指定玩家的SteamID
--@param #number PlayerID 玩家id
--@param #boolean returnNum 是否返回数值，默认返回的是字符串形式
function m.GetSteamID(PlayerID,returnNum)
	if returnNum then
		PlayerResource:GetSteamID(PlayerID)
	else
		return tostring(PlayerResource:GetSteamID(PlayerID));
	end
end

---获取指定玩家的AccountID（玩家信息能看到的那一串数字）
--@param #number PlayerID 玩家id
--@param #boolean returnNum 是否返回数值，默认返回的是字符串形式
function m.GetAccountID(PlayerID,returnNum)
	if returnNum then
		return PlayerResource:GetSteamAccountID(PlayerID);
	else
		return tostring(PlayerResource:GetSteamAccountID(PlayerID));
	end
end

--禁止传送
function m.DisabledTP(PlayerID)
	m.setAttrByPlayer(PlayerID,"_PlayerCanTP",false)
end

--允许传送
function m.EnableTP(PlayerID)
	m.setAttrByPlayer(PlayerID,"_PlayerCanTP",true)
end


---返回玩家是否可以进行传送<p>
--满足以下所有条件可以传送：
--<ol>
--	<li>玩家有控制的英雄</li>
--	<li>英雄非死亡、非眩晕、非冰冻</li>
--	<li>没有因为其他原因被禁止飞行(调用PlayerUtil:DisabledTP(PlayerID))</li>
--</ol>
function m.CanTP(PlayerID)
	local hero = m.GetHero(PlayerID)
	if not hero then
		return false;
	end
	local canTP = m.getAttrByPlayer(PlayerID,"_PlayerCanTP") or true;--没有设置，默认就是true，可以飞
	return hero:IsAlive() 
			and not hero:IsStunned() 
			and not hero:IsFrozen() 
			and canTP;
end


return m;
