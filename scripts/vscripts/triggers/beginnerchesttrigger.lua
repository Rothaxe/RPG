function OnStartTouch1(trigger)
	local waypoint = Entities:FindByName(nil, "begginerchest")
	local pos = waypoint:GetAbsOrigin()
	local item = CreateItem("item_initial_equip_lottery", nil, nil)
	local drop = CreateItemOnPositionSync( pos, item )
	item:LaunchLoot(false, 500, 0.5, pos)
end
