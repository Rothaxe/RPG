require('util/playerutil')
require('util/helperfunc')

function teleporthome(trigger)
	local unit = trigger.activator
	local PlayerID = unit:GetPlayerOwnerID();
	target = Entities:FindByName(nil, "home1")
	Teleport(unit,target:GetAbsOrigin())
	unit:Stop()
	if unit:IsRealHero() then
		--设置镜头
		--if unit:getAttrByPlayer(PlayerID,"changeMoveCameraState") then
			--镜头跟随英雄
			PlayerResource:SetCameraTarget(PlayerID,unit)
			--需要释放镜头，否则会一直绑定在英雄身上;隔1s再释放镜头，否则可能镜头移动到一半就丢失了
			Timer(0.5,
				function()
					PlayerResource:SetCameraTarget(PlayerID,nil)
				end);
		--end
	end
	return true;
end

function teleportgate1(trigger)
	local unit = trigger.activator
	local PlayerID = unit:GetPlayerOwnerID();
	target = Entities:FindByName(nil, "gate1")
	Teleport(unit,target:GetAbsOrigin())
	unit:Stop()
	if unit:IsRealHero() then
		--设置镜头
		--if unit:getAttrByPlayer(PlayerID,"changeMoveCameraState") then
			--镜头跟随英雄
			PlayerResource:SetCameraTarget(PlayerID,unit)
			--需要释放镜头，否则会一直绑定在英雄身上;隔1s再释放镜头，否则可能镜头移动到一半就丢失了
			Timer(0.5,
				function()
					PlayerResource:SetCameraTarget(PlayerID,nil)
				end);
		--end
	end
	return true;
end

function teleportwolfboss(trigger)
	local unit = trigger.activator
	local PlayerID = unit:GetPlayerOwnerID();
	target = Entities:FindByName(nil, "wolfboss")
	Teleport(unit,target:GetAbsOrigin())
	unit:Stop()
	if unit:IsRealHero() then
		--设置镜头
		--if unit:getAttrByPlayer(PlayerID,"changeMoveCameraState") then
			--镜头跟随英雄
			PlayerResource:SetCameraTarget(PlayerID,unit)
			--需要释放镜头，否则会一直绑定在英雄身上;隔1s再释放镜头，否则可能镜头移动到一半就丢失了
			Timer(0.5,
				function()
					PlayerResource:SetCameraTarget(PlayerID,nil)
				end);
		--end
	end
	return true;
end

function teleportwolfcave(trigger)
	local unit = trigger.activator
	local PlayerID = unit:GetPlayerOwnerID();
	target = Entities:FindByName(nil, "wolfcave")
	Teleport(unit,target:GetAbsOrigin())
	unit:Stop()
	if unit:IsRealHero() then
		--设置镜头
		--if unit:getAttrByPlayer(PlayerID,"changeMoveCameraState") then
			--镜头跟随英雄
			PlayerResource:SetCameraTarget(PlayerID,unit)
			--需要释放镜头，否则会一直绑定在英雄身上;隔1s再释放镜头，否则可能镜头移动到一半就丢失了
			Timer(0.5,
				function()
					PlayerResource:SetCameraTarget(PlayerID,nil)
				end);
		--end
	end
	return true;
end