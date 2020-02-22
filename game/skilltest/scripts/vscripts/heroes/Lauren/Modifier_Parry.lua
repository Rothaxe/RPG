--[[
	2010.02.12
	已知bug：1，某些情况下，回血技能或者buff会刷新计算掉血的pivot血量，导致当前层吸收伤害超过最大血量的x%。
				eg.掉5%血又加了15%血，会从新血量重新计算
			2，技能升级以后如果在buff层数没变的情况下，无法获取最新等级的最大层数，层数变化以后恢复正常(已修复)
			3，如果网不好，主动技能可能会延迟生效（待测试验证）
]]


if Modifier_Parry == nil then
    Modifier_Parry = class({})
end



function Modifier_Parry:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end


function Modifier_Parry:OnCreated()
	self.parry_reduced_damage = self:GetAbility():GetSpecialValueFor( "reduced_damage" )
	self.parry_max_stacks= self:GetAbility():GetSpecialValueFor("max_stacks")
	--计算掉血的旧写法，别删，可能有用
	--self.parry_hurt_health_ceiling = self:GetAbility():GetSpecialValueFor("hurt_health_ceiling")
	--self.parry_hurt_health_floor = self:GetAbility():GetSpecialValueFor("hurt_health_floor")
	self.parry_hurt_health_step = self:GetAbility():GetSpecialValueFor("hurt_health_step")
	self.parry_recovery_time = self:GetAbility():GetSpecialValueFor("recovery_time")
	self.prev_health_perc = 0
	self.health_loss = 0
	self.count = 0


    if IsServer() then
        self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.1) 
    end
end

function Modifier_Parry:OnIntervalThink()
	if IsServer() then

		--[[主动技能(旧写法备份)
		local active = self.active
		if active == 1 then
    		--print(self.parry_max_stacks)
    		self:SetStackCount(self.parry_max_stacks)
    	end
    	if active == 0 then
    		self:SetStackCount(0)
    	end
    	]]

		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()
		local prev_health = self.prev_health_perc
		local health_perc = caster:GetHealthPercent()/100
		local newStackCount = oldStackCount
		local recovery_time = self.parry_recovery_time
		local hurt_health_step = self.parry_hurt_health_step
		self.count = self.count + 0.1
		--print(self.count)
		--print(recovery_time)


	    
	    --[[	计算掉几层（旧写法，参考神灵，固定血量百分比为分界线）
	    local hurt_health_ceiling = self.parry_hurt_health_ceiling
		local hurt_health_floor = self.parry_hurt_health_floor
	    for pivot_health = hurt_health_ceiling, hurt_health_floor, -hurt_health_step do
	        if prev_health >= pivot_health then
	        	if health_perc < pivot_health then
	            	newStackCount = newStackCount - 1
	        	else
	       			break
	        	end
	        end
	    end
	    ]]

	    --计算掉几层

	    if health_perc < prev_health then
	  		self.health_loss = self.health_loss + (prev_health - health_perc)
	  		--print(self.health_loss)
	    	local stack_loss = math.floor(self.health_loss /  hurt_health_step)
	    	newStackCount = newStackCount - stack_loss
	    	self.health_loss = self.health_loss - hurt_health_step * stack_loss
	    end
	    self.prev_health_perc = health_perc
	    --[[ 旧写法，debug备用
		if health_perc > prev_health then
	    	self.prev_health_perc = health_perc
	    else
	    	local stack_loss = math.floor((prev_health - health_perc) /  hurt_health_step)
	    	newStackCount = newStackCount - stack_loss
	    	self.prev_health_perc = prev_health - hurt_health_step * stack_loss
	    end
	    ]]
	    --print(self.prev_health_perc)

	    if newStackCount < 0 then
	    	newStackCount = 0
	    end

	    --每隔x秒多一层
	    if self.count >= recovery_time then
	    	newStackCount = newStackCount + 1
	    	self.count = 0
	    end

		
	    if newStackCount > self.parry_max_stacks then
	    	newStackCount = self.parry_max_stacks
	    end
	   
    	local difference = newStackCount - oldStackCount

    	-- set stackcount
    	if difference ~= 0 then
    		self:SetStackCount( newStackCount )
    		self:ForceRefresh()
    	end
	end
end

--修改模型（后续修改）
function Modifier_Parry:OnRefresh()
	self.parry_max_stacks = self:GetAbility():GetSpecialValueFor( "max_stacks" )
	self.reduced_damage = self:GetAbility():GetSpecialValueFor( "reduced_damage" )

    if IsServer() then
        self:GetParent():CalculateStatBonus()
    end
end

--[[
function Modifier_Parry:Active(params)
	self.parry_max_stacks = params
	local a = self:GetStackCount()
	print (a)
	if IsServer() then
		--self:SetStackCount(parry_max_stacks)
	end
end
]]

function Modifier_Parry:IsPurgable() 
	return false 
end

function Modifier_Parry:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function Modifier_Parry:GetModifierIncomingDamage_Percentage( params )
	if self:GetStackCount() == 0 then
		return 0
	else
		return self.parry_reduced_damage
	end
end


function Modifier_Parry:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"
end