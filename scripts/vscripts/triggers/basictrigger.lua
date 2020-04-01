function OnStartTouch1(trigger)
	local waypoint = Entities:FindByName(nil, "begginerchest")
	local pos = waypoint:GetAbsOrigin()
	local item = CreateItem("item_initial_equip_lottery", nil, nil)
	local drop = CreateItemOnPositionSync( pos, item )
	item:LaunchLoot(false, 500, 0.5, pos)
end

function OnStartTouch2(trigger)
	local Waypoint = Entities:FindByName(nil, "spiderboss")
	local pos = Waypoint:GetAbsOrigin()
    local boss = CreateUnitByName("SpiderBoss", pos, true, nil, nil, DOTA_TEAM_BADGUYS)
    boss:SetForwardVector(RandomVector(400))
    boss:SetContext( "name", "spiderboss", 0 )
    boss:SetOwner(Waypoint)
end

function screenshake()
	local Waypoint = Entities:FindByName(nil, "spiderbosstrigger")
	local pos = Waypoint:GetAbsOrigin()
	 --ScreenShake  Start a screenshake with the following parameters. vecCenter, flAmplitude, flFrequency, flDuration, flRadius, eCommand( SHAKE_START = 0, SHAKE_STOP = 1 ), bAirShake
   	ScreenShake(pos, 200, 8, 2 , 9000, 0, true)
end