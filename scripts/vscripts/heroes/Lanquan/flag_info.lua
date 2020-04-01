--旗帜自身属性
flag_info = flag_info or class({})

function flag_info:OnCreated(keys)
	if IsServer() then 
		self.parent = self:GetParent()
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.ground_height = GetGroundHeight(self.pos, self.parent)
		self.pos.z = 5000
		self.speed = 500
		self:StartIntervalThink(FrameTime())
	end
end

function flag_info:OnIntervalThink()
	if self.pos.z - self.ground_height > 0 then
		self.pos.z =  self.pos.z - self.speed
		self.parent:SetOrigin(self.pos)
	else
		if self.pos.z < self.ground_height then
			self.pos.z = self.ground_height
			self.parent:SetOrigin(self.pos)
		end
		return -1
	end
end
function flag_info:CheckState()
	local state = {
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true;
	}
	return state
end

function flag_info:IsHidden() 				return true end
function flag_info:Isbuff() 				return true end
function flag_info:IsPurgable() 			return false end