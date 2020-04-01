LinkLuaModifier("Modifier_Twine", "heroes/Arven/Modifier_Twine.lua", LUA_MODIFIER_MOTION_NONE)


CirrusRoot = class({})

function CirrusRoot:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration") 
	local radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

					--[[ 初始伤害（按需添加）
					local damage = {
						victim = enemy,
						attacker = caster,
						damage = self:GetSpecialValueFor("damage_per_sec"),
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self
					}
					ApplyDamage( damage )
					]]
					--print (duration)
					local modifier = enemy:AddNewModifier( caster, self, "Modifier_Twine", {duration = duration} )
					--计算抗性
					--modifier:SetDuration(duration * (1 - enemy:GetStatusResistance()), true)
				end
			end
		end
	end
end