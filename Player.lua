-- Contains the definition of the Player object used to make predictions with.

local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                                PLAYER OBJECT                                                       --
------------------------------------------------------------------------------------------------------------------------
Pred.Player = {
    name = UnitName('player'),
    class = UnitClass('player'),
    spec = nil,         -- Updated during update spells
    talents = {},       -- the currently selected talents
    gear = {},          -- the currently equipped gear
    enchants = {},      -- the current enchants                             TODO
    artifact = nil,     -- the currently equipped artifact, if present      TODO
    tier = {},          -- will hold tier bonuses e.g. {'20.2', '21.4'}     TODO
    haste = 0,          -- used to calculate predicted cast times
    hp_percent = 0,     -- influences addon decisions
    resources = {},     -- Will be populated by Enum.PowerType
    maxResources = {},  -- Holds the maximum value of each PowerType
    runes = nil,        -- holds information about current rune state
    
    -- A list of buffs the player has, which may influence future CDs through effects.
    buffs = {},

    -- The list of debuffs active, which are used via rules to calculate actions.
    debuffs = {},
    
    -- List of available spells. Updated by a RELOAD event.
    spells = {},
} -- Pred.Player -------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
--                                               PLAYER FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Time = Pred.Time
local Player = Pred.Player
local Spell = Pred.Spell
local Options = Pred.Options
local Data = Pred.Data

-- Gets the spell list. NB. This is only called on the player, and as the result of a non-tick Event.
function Pred.Player:GetSpellList()

    Player.name = GetUnitName('player')
    Player.class = UnitClass('player')
    local _, spec = GetSpecializationInfo(GetSpecialization())
    Player.spec = spec

    local cds = {}
    local skillType, spellId, name, spellStart, spellEnd
    
    -- Cycle through combat spells in the spell book
    _, _, spellStart = GetSpellTabInfo(1) -- Assumes 2 is the current spec.
    _, _, spellEnd = GetSpellTabInfo(3)   -- Assumes 3 is the next spec.
    for i = tonumber(spellStart), tonumber(spellEnd) do
        skillType, spellId = GetSpellBookItemInfo(i, 'spell')
        if spellId then
            if IsSpellKnown(spellId) then
                name = GetSpellInfo(spellId)
                -- Need to check for passives of spells we already know
                if not IsPassiveSpell(i, 'spell') then
                    Pred:PrintDebug('Added ' .. name)
                    if name then    -- Safety - Shaman's (at least) have a fake spellId
                        cds[name] = Spell:CreateFromSpellId(spellId, name)
                    end
                end
            end
        end
    end
    
    Pred.tempSpells = cds
end -- Pred.Player:GetSpellList ----------------------------------------------------------------------------------------


-- Get aura list for the palyer
function Pred.Player:GetAuraList(func)

    -- Get all auras for the target
    local auras, i = { }, 1
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = func('player', i)
    while name do
        auras[name] = {}
        auras[name].count = count
        auras[name].timeRemaining = expirationTime - Time.Now
        auras[name].caster = unitCaster
        i = i + 1
        name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = func('player', i)
    end
    
    -- Check for totems
    for i = 1, 4 do
        local tHave, tName, tStartTime, tDuration = GetTotemInfo(i)
        if tHave and tName then -- Have encountered issue where WoW returns nil for tName on rare occasions!
            auras[tName] = {}
            auras[tName].timeRemaining = tStartTime + tDuration - Time.Now
        end
    end
    
    return auras
end -- Pred.Player:GetAuraList(func) -----------------------------------------------------------------------------------


-- Refreshes the given spell's current data
function Pred.Player:RefreshSpell(spellName)

    -- Safety
    if not spellName then 
        return
    end
    
    local spell, haste = Player.spells[spellName], Player.haste
    
    -- current charges
    local chargeStart, chargeDuration, _
    spell.currentCharges, spell.maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell.spellId)
    -- Adjust cooldown for recharge abilities
    if chargeDuration then
        spell.baseCooldown = chargeDuration
        if Data[Player.class][Player.spec].HastedCooldowns[spell.spellId] then
            spell.baseCooldown = spell.baseCooldown * (1 + haste)
        end
    end
    
    -- castTime
    _, _, _, spell.castTime = GetSpellInfo(spell.spellId)
    spell.castTime = Pred:SanitizeTime(spell.castTime)

    -- baseCastTime.
    spell.baseCastTime = spell.castTime * (1 + haste)

    -- remainingCooldown.
    if not chargeStart then
        local start, duration = GetSpellCooldown(spell.spellId)
        spell.remainingCooldown = start + duration - Time.Now
    else
        spell.remainingCooldown = chargeStart + chargeDuration - Time.Now
    end

    -- Adjust for latency
    spell.remainingCooldown = spell.remainingCooldown - Options.latency
    if spell.maxCharges and spell.remainingCooldown <= 0 and spell.currentCharges < spell.maxCharges then
        spell.currentCharges = spell.currentCharges + 1
        spell.remainingCooldown = spell.remainingCooldown + (Data[Player.class][Player.spec].HastedCooldowns[spell.spellId] and spell.baseCooldown / (1 + Player.haste) or spell.baseCooldown)
    end
    -- Ensure 0 if finished.
    spell.remainingCooldown = math.max(spell.remainingCooldown, 0)

end -- Pred.Player:RefreshSpell(spellName) -----------------------------------------------------------------------------


-- Updates spells with all current information. NB. This needs to happen after player update so we have a haste value
-- to calculate baseCastTime with.
function Pred.Player:RefreshAllSpells()
    
    local _
    for _, v in pairs(Player.spells) do
        Pred.Player:RefreshSpell(v.name)
    end
end -- Pred.Player:RefreshAllSpells ------------------------------------------------------------------------------------


-- Updates player information.
function Pred.Player:Update()
    
    -- Get hp percent, if available (should be, only using player and target)
    Player.hp_percent = UnitHealth('player') / UnitHealthMax('player')

    -- Get haste value, and spells, if available.
    Player.haste = tonumber(GetHaste()) / 100    -- Haste comes in readable form, need to fix it
    
    -- Resources
    for k, v in pairs(Enum.PowerType) do
        Player.resources[k] = UnitPower('player', v)
        Player.maxResources[k] = UnitPowerMax('player', v)
    end
    
    -- Runes
    local playerClass = UnitClass('player')
    if playerClass == 'Death Knight' then
        Player.runes = {}
        Player.runes.available = 0;
        for i = 1, 6 do
            local start, cd, ready = GetRuneCooldown(i)
            Player.runes[i] = ready and 0 or start + cd - Time.Now
            if ready then
                Player.runes.available = Player.runes.available + 1
            end
        end
        -- Do we need to sort the table here?
    end
    
    -- Get buffs
    Player.buffs = Pred.Player:GetAuraList(UnitBuff)
    Player.debuffs = Pred.Player:GetAuraList(UnitDebuff)
    
    -- Update spell information
    Pred.Player:RefreshAllSpells()

end -- Pred.Player:Update ----------------------------------------------------------------------------------------------


-- Load the player's talents
function Pred.Player:UpdateTalents()
    local talentName, selected = "", false
    
    -- Configure player talents.
    Player.talents = {}
    for i = 1, 7 do
        for j = 1, 3 do
            _, talentName, _, selected = GetTalentInfo(i, j, 1)
            if selected then
                Player.talents[talentName] = true
            end
        end
    end
end -- Pred.Player:UpdateTalents ---------------------------------------------------------------------------------------


-- Updates the player's gear
function Pred.Player:GetGearList()
    -- Configure player gear
    Player.gear = {}
    local itemLink, itemName
    for i = 1, 17 do
        itemLink = GetInventoryItemLink('player', i)
        if itemLink then
            itemName = GetItemInfo(itemLink)
            if itemName then
                Player.gear[itemName] = true
            end
        end
    end
    
    -- Artifact         TODO
    -- Enchants         TODO
    -- Tier Bonuses     TODO
end -- Pred.Player:GetGearList -----------------------------------------------------------------------------------------


-- Print out the current State in readable form
function Pred.Player:Print()
    
    local ret = {
        Player.name,
        '\n  Haste = ',
        tostring(Player.haste),
        '\n  HP% = ',
        Player.hp_percent,
        '\n\nResources:\n  ',
    }
    local _
    
    -- Resources
    for k, v in pairs(Player.resources) do
        ret[#ret + 1] = string.format('%s=%d ', k, v)
    end
    ret[#ret + 1] = '\nMaximums:\n'
    for k, v in pairs(Player.maxResources) do
        ret[#ret + 1] = string.format('%s=%d ', k, v)
    end
    ret[#ret + 1] = '\n'
    
    -- Runes
    if Player.runes then
        ret[#ret + 1] = string.format('Runes (%d):', Player.runes.available)
        for i = 1, 6 do
            ret[#ret + 1] = string.format(' %0.3f', Player.runes[i])
        end
        ret[#ret + 1] = '\n'
    end
    
    -- Talents
    ret[#ret + 1] = '\nTalents:\n  '
    for k, _ in pairs(Player.talents) do
        ret[#ret + 1] = string.format('%s; ', k)
    end
    ret[#ret + 1] = '\n\n'

    -- Gear
    if Player.gear then
        ret[#ret + 1] = 'Gear:\n'
        for k in pairs(Player.gear) do
            ret[#ret + 1] = string.format('%s; ', k)
        end
        ret[#ret + 1] = '\n'
    end
    
    -- Artifact         TODO
    -- Enchants         TODO
    -- Tier Bonuses     TODO
    
    -- Buffs
    ret[#ret + 1] = '  Buffs:\n'
    for n, v in Pred:OrderedByKeys(Player.buffs) do
        ret[#ret + 1] = string.format('    %-30s', n)
        for l, u in Pred:OrderedByKeys(v) do
            ret[#ret + 1] = string.format('%s[%s], ', tostring(l), tostring(u))
        end
        ret[#ret + 1] = '\n'
    end

    -- Debuffs
    ret[#ret + 1] = '  Debuffs:\n'
    for n, v in Pred:OrderedByKeys(Player.debuffs) do
        ret[#ret + 1] = string.format('    %-30s', n)
        for l, u in pairs(v) do
            ret[#ret + 1] = string.format('%s[%s], ', tostring(l), tostring(u))
        end
        ret[#ret + 1] = '\n'
    end

    -- Spells
    if #Options.overlaySpellList > 0 then
        for i = 1, #Options.overlaySpellList do
            if Player.spells[Options.overlaySpellList[i]] then
                ret[#ret + 1] = Pred.Spell:Print(Player.spells[Options.overlaySpellList[i]])
            end
        end
    elseif Options.overlaySpells then
        ret[#ret + 1] = Pred.Spell:PrintAll(Player.spells)
    end
    
    return table.concat(ret, "")
end -- Pred.Player:Print -----------------------------------------------------------------------------------------------


-- Check if and what we are casting.
function Pred.Player:GetCurrentCast()

    local spellName = nil
    local percent = 1, _
    local currentTime = Time.Now
    local spellTimeEnd = currentTime

    -- Need to check if anything is being cast, channeled or if we're on GCD.
    local castName, _, _, castIconPath, castStartTime, castEndTime, isTradeSkill = UnitCastingInfo('player')
    if isTradeSkill then castName = nil end
    castStartTime = Pred:SanitizeTime(castStartTime)
    castEndTime = Pred:SanitizeTime(castEndTime)
    if castName then
        -- Safety
        if castEndTime > castStartTime then
            percent = (currentTime - castStartTime) / (castEndTime - castStartTime)
            -- This handles awkward cases of GCD firing before casts. Might need to figure out how to make it better.
            -- Also need to check there was a last GCD!
            if (Time.lastGCD) then
                if percent <= (3 * Time.lastGCD) and Time.lastGCD > 0 then
                    percent = Time.lastGCD + percent / (3 * Time.lastGCD) * (2 * Time.lastGCD)
                end
            end
            spellTimeEnd = castEndTime
        end
        spellName = castName
    else
        -- Check for channeled abilities.
        local channelName, _, _, channelIconPath, channelStartTime, channelEndTime, isTradeSkill = UnitChannelInfo('player')
        if isTradeSkill then channelName = nil end
        channelStartTime = Pred:SanitizeTime(channelStartTime)
        channelEndTime = Pred:SanitizeTime(channelEndTime)
        if channelName then
            -- Safety
            if channelEndTime > channelStartTime then
                percent = (currentTime - channelStartTime) / (channelEndTime - channelStartTime)
                -- This handles awkward cases of GCD firing before casts. Might need to figure out how to make it better.
                if percent <= (3 * Time.lastGCD) and Time.lastGCD > 0 then
                    percent = Time.lastGCD + percent / (3 * Time.lastGCD) * (2 * Time.lastGCD)
                end
                spellTimeEnd = channelEndTime
            end
            spellName = channelName
        else
            -- Check for global cooldown.
            local gcdStart, gcdDuration = GetSpellCooldown(SPELL_GLOBAL_COOLDOWN)
            if gcdDuration > 0 then
                percent = (currentTime - gcdStart) / gcdDuration
                -- TODO: This handles awkward cases of GCD firing before casts. Might need to figure out how to make it better.
                if percent < 0.25 then
                    Time.lastGCD = percent
                else
                    Time.lastGCD = 0.01
                end
                spellTimeEnd = gcdStart + gcdDuration
                spellName = 'GCD'
            end
            
        end
    end
    if percent > 1 then percent = 1 end

    return percent, spellName, spellTimeEnd
end -- Pred.Player:GetCurrentCast --------------------------------------------------------------------------------------