-- Contains the definition of the Target object used to make predictions with.

local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                                TARGET OBJECT                                                       --
------------------------------------------------------------------------------------------------------------------------

Pred.Target = {
    name = nil,         -- used for determining if calculations are made / GUI is shown
    hp_percent = 0,     -- influences addon decisions
    resources = {},     -- Will be populated by Enum.PowerType
    
    -- A list of buffs the target has, which may influence spell choice.
    buffs = {},

    -- The list of debuffs active, which are used via rules to calculate actions.
    debuffs = {},
    
} -- Pred.Target --------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
--                                               TARGET FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Target = Pred.Target

-- Get aura list for target
function Pred.Target:GetAuraList(func, castByPlayer)

    -- Get all auras for the target
    local auras, i = { }, 1
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = func('target', i)
    while name do
        -- Only check for debuffs by the player
        if (castByPlayer and unitCaster == 'player') or not castByPlayer then
            auras[name] = {}
            auras[name].count = count
            auras[name].timeRemaining = expirationTime - Pred.Time.Now
            auras[name].caster = unitCaster
        end
        i = i + 1
        name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = func('target', i)
    end
   
    return auras
end -- Pred.Target:GetAuraList(func, castByPlayer) ---------------------------------------------------------------------


-- Updates the target, if it exists.
function Pred.Target:Update()
    
    -- Check target exists
    if UnitExists('target') then
    
        Target.name = UnitName('target')
    
        -- Get hp percent, if available (should be, only using player and target)
        Target.hp_percent = UnitHealth('target') / UnitHealthMax('target')
        
        -- Resources
        for k, v in pairs(Enum.PowerType) do
            Target.resources[k] = UnitPower('target', v)
        end
        
        -- Get buffs
        Target.buffs = Target:GetAuraList(UnitBuff, false)
        Target.debuffs = Target:GetAuraList(UnitDebuff, true)
    
    else
        Target.name = nil
    end

end -- Pred.Target:Update ----------------------------------------------------------------------------------------------


-- Print out the current Target in readable form
function Pred.Target:Print()
    
    -- Safety
    if not Target.name then
        return ''
    end
    
    local ret = {
        'Target = ',
        Target.name,
        '\nHP% = ',
        Target.hp_percent,
        '\nResources: ',
    }

    local _
    
    -- Resources
    for k, v in pairs(Target.resources) do
        ret[#ret + 1] = string.format('%s=%d ', k, v)
    end
    ret[#ret + 1] = '\n'
    
    -- Buffs
    for n, v in Pred:OrderedByKeys(Target.buffs) do
        ret[#ret + 1] = string.format('\t%-30s\t', n)
        for l, u in Pred:OrderedByKeys(v) do
            ret[#ret + 1] = string.format('%s[%s], ', l, u)
        end
        ret[#ret + 1] = '\n'
    end

    -- Debuffs
    for n, v in Pred:OrderedByKeys(Target.debuffs) do
        ret[#ret + 1] = string.format('\t%-30s\t', n)
        for l, u in pairs(v) do
            ret[#ret + 1] = string.format('%s[%s], ', l, u)
        end
        ret[#ret + 1] = '\n'
    end

    return table.concat(ret, "")
end -- Pred.Target:Print -----------------------------------------------------------------------------------------------