item_initial_equip_lottery = class({})
require ('util/helperfunc')

function item_initial_equip_lottery:OnSpellStart()
local caster = self:GetCaster()
local looteffect = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_eggbeater_jackpot_spindle_rig_secondstlye.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
ParticleManager:SetParticleControl(looteffect, 0, caster:GetAbsOrigin())
end

function item_initial_equip_lottery:OnChannelFinish(bInterrupted)
    if bInterrupted then
    return
    else
    local unit = "item_initial_equip_lottery"
    local owner = self:GetCaster()
    ItemRollDrops(unit, owner)
    owner:RemoveItem(self)
    end
end