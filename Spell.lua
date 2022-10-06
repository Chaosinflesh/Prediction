-- Contains the definition of the Spell object

local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                                 SPELL OBJECTS                                                      --
------------------------------------------------------------------------------------------------------------------------

SPELL_GLOBAL_COOLDOWN = 61304

local SpellType = {
    spellId,                -- The id of the spell
    name,                   -- The name of the spell
    icon,                   -- Path to the icon file
    baseCastTime,           -- Cast time without haste taken into account
    castTime,               -- Current cast time
    baseCooldown,           -- Cooldown without haste and abilities taken into account
    effects = {},           -- List of effects that this spell has on successful cast
    maxCharges,             -- How many charges this spell may have
    currentCharges,         -- How many charges the spell currently has
    remainingCooldown,      -- How long (in seconds) till reusable
    
} -- Spell -------------------------------------------------------------------------------------------------------------

Pred.Spell = {}

------------------------------------------------------------------------------------------------------------------------
--                                                SPELL FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Options = Pred.Options
local Player = Pred.Player
local Time = Pred.Time

-- Creates a new Spell
function Pred.Spell:New()
    return Pred:Clone(SpellType)
end -- Pred.Spell:New --------------------------------------------------------------------------------------------------


-- Creates a new Spell from the specified target, i.e. the player or mob.
function Pred.Spell:CreateFromSpellId(spellId, name)

    local obj = Pred.Spell:New()

    local _, _, icon = GetSpellInfo(spellId)
    obj.spellId = spellId
    obj.name = name
    obj.icon = icon
    obj.baseCooldown = Pred:SanitizeTime(GetSpellBaseCooldown(spellId))
    
    return obj
end -- Pred.Spell:CreateFromSpellId(spellId, name) ---------------------------------------------------------------------


-- Print out the current Spell in readable form
function Pred.Spell:Print(o)
    
    -- Safety
    if not o then
        return ''
    end
    
    ret = {
        string.format('%-40s[%6d] (', o.name, o.spellId),
    }
    
    if o.currentCharges and o.maxCharges then
        ret[#ret + 1] = string.format('%d/%d) CT=', o.currentCharges, o.maxCharges)
    else
        ret[#ret + 1] = '0/0) CT='
    end
    if o.castTime and o.baseCastTime then
        ret[#ret + 1] = string.format('%2.3f (%2.3f), CD=', o.castTime, o.baseCastTime)
    else
        ret[#ret + 1] = 'n/a (n/a), CD='
    end
    if o.remainingCooldown and o.baseCooldown then
        ret[#ret + 1] = string.format('%2.3f (%2.3f)', o.remainingCooldown, o.baseCooldown)
    else
        ret[#ret + 1] = 'n/a (n/a)'
    end

    return table.concat(ret, "")
end -- Pred.Spell:Print(o) ---------------------------------------------------------------------------------------------


-- Print out the list of spells.
function Pred.Spell:PrintAll(spellList)
    
    -- Safety
    if not spellList then
        return ''
    end
    
    local _
    local ret = {
        '  Spells:\n',
    }
    
    for _, v in Pred:OrderedByKeys(spellList) do
        ret[#ret + 1] = '    ' .. Pred.Spell:Print(v) .. '\n'
    end
    
    return table.concat(ret, "")
end -- Pred.Spell:PrintAll(spellList) ----------------------------------------------------------------------------------