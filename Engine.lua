-- Contains routines for making predictions

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                               ENGINE FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

Pred.Engine = {}

local Options = Pred.Options
local Overlay = Pred.Overlay
local Player = Pred.Player
local Target = Pred.Target
local Time = Pred.Time
local Rules = Pred.Rules

-- Used to hold prediction values.
Pred.Predictions = {}
Pred.DelayedEffects = {}

-- Calculate the actions to the n-th degree, as specified by depth
-- Returns an array of spell names, such that [0] = secondBest, [1] = best, [2] = bestNext, [3] = bestNextNext... etc.
function Pred.Engine:CalculateActions(depth, includeSecondBest)

    if depth > PREDICTION_DEPTH then
        return
    end
    
    -- 1. Calculate best action in current state.
    local best, second = Rules:FindBestSpell(includeSecondBest)
    Pred.Predictions[depth] = best
    -- 1.5. If secondBest calculate second best action.
    if includeSecondBest then
        Pred.Predictions[5] = second
    end
    
    -- 2. Apply effects of that action.
    Pred.Engine:ApplySpellEffects(best)
    
    -- 3. Recurse as required.
    Pred.Engine:CalculateActions(depth + 1)
end -- Pred:CalculateActions(depth) ------------------------------------------------------------------------------------


-- Run the actual engine
function Pred.Engine:Run()

    -- Check if spells have been updated.
    if Pred.tempSpells then
        Player.spells = Pred.tempSpells
        Pred.tempSpells = nil
    end

    if Options.overlay == "on" then
        Overlay:Clear()
        Overlay:Show()
    else
        Overlay:Hide()
    end
    
    -- Get current states
    Player:Update()
    Target:Update()
    
    -- Overlay output
    Overlay:Append('Player:\n' .. Player:Print() .. '\n')
    Overlay:Append('Target:\n' .. Target:Print() .. '\n')
    
    -- Early skip in the event of no target; Set
    if Pred.Target.name and (not UnitIsFriend('player', 'target')) then
        
        -- 1st time, check if we're currently casting.
        local _, spellName, castTimeEnd = Player:GetCurrentCast()

        -- Set the Future time -> all prediction functions run off this.
        Time.Future = Time.Now
        if spellName then
            Pred.Engine:ApplySpellEffects(spellName, castTimeEnd)
        end
        
        -- Calculate the actions to a specified depth
        Pred.Engine:CalculateActions(1, Options.secondBest == 'on')
        
        -- Update Overlay
        Overlay:Append('Predictions:' .. tostring(#Pred.Predictions) .. '\n')
        for k, v in pairs(Pred.Predictions) do
            Overlay:Append('  [' .. tostring(k) .. '] ' .. v .. '\n')
        end
    end

    -- Update the GUI here.
    Pred.GUI:Update(Pred.Predictions)
    
end -- Pred:RunEngine --------------------------------------------------------------------------------------------------


-- Apply effects from the current spell, whilst winding down pre-existing effects.
function Pred.Engine:ApplySpellEffects(spellName, castTimeEnd)

    -- Safety. Check if we have a chosen ruleset and it exists
    if not Pred.CurrentRuleSet then
        return
    end
    local SpellEffects = Pred.CurrentRuleSet.SpellEffects
    local _
    local spell = Player.spells[spellName]
    local setup = PLAYER_ENV_SETUP
    local loadstring = Pred:Memoize(loadstring)

    Pred.overrideGCDValue = nil
    Pred.castBecameInstant = nil
    
    -- We may not have a spell - if this is called on GCD, spell will be nil.
    -- castTimeEnd will be given if we're on GCD, or mid-cast.
    -- castTimeEnd only arrives if we're part-way through a cast. Don't cast Instant effects in this scenario.
    if spell and not castTimeEnd then
        local cdLeft, chargeChange = 0, nil
        -- 2. Apply the instant effects of the cast. If we're already casting, don't.
        if not castTimeEnd then
            if SpellEffects[spellName] and SpellEffects[spellName].Instant then
                assert(loadstring(setup .. SpellEffects[spellName].Instant))()
                if Options.overlayPrediction then
                    Overlay:Append("Applied " .. spellName .. ".Instant\n")
                end
            end
        end -- 2. Calculated Instant actions.
    end
        
    -- 2a. Calculate the spell's cooldown. If it was instant cast, it will be applied immediately, otherwise upon cast completion.
    if spell then
        if Pred.Data[Player.class][Player.spec].HastedCooldowns[spell.spellId] then
            cdLeft = spell.baseCooldown / (1 + Player.haste)
        else
            cdLeft = spell.baseCooldown
        end
        -- 2b. Check charges
        if spell.maxCharges and spell.maxCharges > 0 then
            chargeChange = -1
        end

        -- 2c. Check if it was off the GCD.
        if Pred.overrideGCDValue and Pred.overrideGCDValue <= 0 then
            spell.remainingCooldown = cdLeft
            spell.currentCharges = spell.maxCharges and (spell.currentCharges + chargeChange) or 0
            if Options.overlayPrediction then
                Overlay:Append(string.format('%s CD updated to %.3ds\n', spellName, spell.remainingCooldown))
            end
            return
        end
        
        --2d. Check if it was an instant cast.
        if spell.baseCastTime == 0 or Pred.castBecameInstant then
            -- Apply cdLeft, chargesLeft to spell
            if spell then
                spell.remainingCooldown = cdLeft
                spell.currentCharges = spell.maxCharges and (spell.currentCharges + chargeChange) or 0
                if Options.overlayPrediction then
                    Overlay:Append(string.format('Applying %s CD=%.3f, Charges=%s\n', tostring(spellName), cdLeft, tostring(spell.currentCharges)))
                end
            end -- spell
        end -- 2d. instant cast.
    end -- 2. Calculate spell's cooldown and charge information

    -- Calculate the time until next able to cast.
    local timeDiff = 0
    if castTimeEnd then
        timeDiff = castTimeEnd - Time.Future + PREDICTION_FRAME_TIME
    elseif Pred.overrideGCDValue then
        timeDiff = Pred.overrideGCDValue
    else
        if spell and spell.baseCastTime > 0 then
            timeDiff = spell.baseCastTime / (1 + Player.haste) + PREDICTION_FRAME_TIME
        else
            -- If everything is on CD, we should really find the lowest CD here. Using GCD instead.
            timeDiff = 1.5 / (1 + Player.haste) + PREDICTION_FRAME_TIME
        end
    end -- Calculated the time until next able to cast.
        
    -- 3. Look for delayed effects. Delayed times have a random hash for the first 8 digits
    for k, v in pairs(Pred.DelayedEffects) do
        if tonumber(k:sub(9)) < timeDiff then
            assert(loadstring(setup .. v))()
            if Options.overlayPrediction then
                Overlay:Append("Applied Delayed ".. v .. "\n")
            end
            Pred.DelayedEffects[k] = nil
        end
    end -- 3. Looked for delayed effects.
        
    -- Advance all player spell cooldowns.
    for sp in pairs(Player.spells) do
        Pred.Engine:AdvanceSpellCooldown(sp, timeDiff)
    end -- Advanced all player spell cooldowns.
    -- Forward Runes if appropriate
    if Player.runes then
        Pred.Engine:AdvanceRuneCooldowns(timeDiff)
    end -- Forward runes
        
    -- 4 & 5. Invoke Buff and Regen Effects. They can invoke GetPeriod() to find out how long they have to apply the effect for.
    Pred.Engine:SetPeriod(timeDiff)
    Pred.Engine:ApplyAllBuffEffects()
    Pred.Engine:ApplyAllRegenEffects()
    Pred.Engine:SetPeriod(nil)
        
    -- Update time for next prediction.
    Time.Future = Time.Future + timeDiff

    -- 6. Invoke SpellEffects.Cast
    if not Pred.castBecameInstant then
        if SpellEffects[spellName] and SpellEffects[spellName].Cast then
            assert(loadstring(setup .. SpellEffects[spellName].Cast))()
            if Options.overlayPrediction then
                Overlay:Append("Applied " .. spellName .. ".Cast\n")
            end
        end
    end -- 6. Invoke SpellEffects.Cast    

    -- Apply cdLeft, chargesLeft to CAST spell
    if spell then
        if spell.baseCastTime > 0 and (not Pred.castBecameInstant) then
            spell.remainingCooldown = cdLeft
            spell.currentCharges = spell.maxCharges and (spell.currentCharges + chargeChange) or 0
            if Options.overlayPrediction then
                Overlay:Append(string.format('Applying %s CD=%.3f, Charges=%s\n', tostring(spellName), cdLeft, tostring(spell.currentCharges)))
            end
        end
    end -- spell
end -- Pred.Engine:ApplySpellEffects(spell, castTimeLeft) --------------------------------------------------------------


-- Move the specified buff/debuff into the future.
function Pred.Engine:AdvanceBuffTimeRemaining(targetName, groupName, buffName, timeDiff)
    -- Safety
    if groupName and buffName then
        local g = Pred[targetName][groupName]
        g[buffName].timeRemaining = g[buffName].timeRemaining - timeDiff
        if g[buffName].timeRemaining <= 0 and (g[buffName.count] and (g[buffName].count <= 0) or true) then
            g[buffName] = nil
        end
    end
end -- Pred.Engine:AdvanceBuffTimeRemaining(targetName, groupName, buffName, timeDiff) ---------------------------------


-- Move the specified spell cooldown into the future.
function Pred.Engine:AdvanceSpellCooldown(spellName, timeDiff)

    -- Safety
    if Player.spells[spellName] then
        if not Player.spells[spellName].remainingCooldown then
            return
        end
        local s = Player.spells[spellName]
        -- Advance cooldown.
        s.remainingCooldown = s.remainingCooldown - timeDiff
        -- Check if a recharge happened
        if s.maxCharges and s.remainingCooldown <= 0 and s.currentCharges < s.maxCharges then
            s.currentCharges = s.currentCharges + 1
            s.remainingCooldown = s.remainingCooldown + (Pred.Data[Player.class][Player.spec].HastedCooldowns[s.spellId] and s.baseCooldown / (1 + Player.haste) or s.baseCooldown)
        end
        -- Set cooldown to 0 if under.
        if s.remainingCooldown <= 0 then
            s.remainingCooldown = 0
        end
    end
end -- Pred.Engine:AdvanceCooldowns(spellName, timeDiff) ---------------------------------------------------------------


-- Advance the runes the specified time. Only 3 runes can regen at a time, so need to account for overflow from early ones.
function Pred.Engine:AdvanceRuneCooldowns(timeDiff)
    Player.runes.available = 0
    for i = 1, 6 do
        Player.runes[i] = Player.runes[i] - timeDiff
        if Player.runes[i] <= 0 then
            Player.runes[i] = 0
            Player.runes.available = Player.runes.available + 1
        end
    end
end -- Pred.Engine:AdvanceRuneCooldowns(timeDiff) ----------------------------------------------------------------------


-- Calculate how the runes are used
function Pred.Engine:UseRunes(number)
    -- Safety. In order to prevent infinite loop crash from bad user input, restrict number of times this can happen.
    if number > Player.runes.available then
        number = Player.runes.available
    end
    while number > 0 do
        -- Find rune we are adjusting. This will find the first rune @ 0.
        local pos = 1
        for i = 2, 6 do
            if Player.runes[i] < Player.runes[pos] then
                pos = i
            end
        end
        -- 3 runes can be charging simultaenously. Blizz implemented this by giving later runes the charge time already
        -- used by earlier runes.
        if Player.runes.available > 3 then
            Player.runes[pos] = 10 / (1 + Player.haste)
        else
            -- Find lowest rune that is not 0
            local older = 1
            while Player.runes[older] == 0 do
                older = older + 1
            end
            for i = older, 6 do
                if Player.runes[i] > 0 and Player.runes[i] < Player.runes[older] then
                    older = i
                end
            end
            -- At this point, older holds the rune closest to finishing. This may be out by a factor of haste (if haste has
            -- changed since the rune was refreshed) but that is minor.
            Player.runes[pos] = 10 / (1 + Player.haste) + Player.runes[older]
        end
        number = number - 1
    end
end -- Pred.Engine:UseRunes(number) ------------------------------------------------------------------------------------


-- Add the specified runes
function Pred.Engine:AddRunes(number)
    -- Sanity
    if not number or number > Player.maxResources['Runes'] then
        number = Player.maxResources['Runes']
    end
    while number > 0 do
        local pos = 1
        for i = 2, 6 do
            if Player.runes[i] > Player.runes[pos] then
                pos = i
            end
        end
        Player.runes[pos] = 0
        Player.runes.available = math.min(Player.maxResources['Runes'], Player.runes.available + 1)
        number = number - 1
    end
end -- Pred.Engine:AddRunes(number) ------------------------------------------------------------------------------------


-- Tells us the spell has a delayed effect: e.g. Elemental Lava Burst with T21_2PC
function Pred.Engine:SetDelayEffect(cd, effect)
end -- Pred.Engine:SetDelayEffect(cd, effect) --------------------------------------------------------------------------


-- Set the period users will have access to.
function Pred.Engine:SetPeriod(timeDiff)
    Pred.effectSpellPeriod = timeDiff
end -- Pred.Engine:SetPeriod(timeDiff) ---------------------------------------------------------------------------------


-- Returns the global duration of this cycle
function Pred.Engine:GetPeriod()
    return Pred.effectSpellPeriod and Pred.effectSpellPeriod or 0
end -- Pred.Engine:GetPeriod -------------------------------------------------------------------------------------------


-- Allows the user to request the GCD be overridden for this spell (in the event it is off the GCD, or a 1s GCD)
function Pred.Engine:OverrideGCD(value)
    if value and value >=0 then
        Pred.overrideGCDValue = value
    end
end -- Pred.Engine:OverrideGCD(value) ----------------------------------------------------------------------------------


-- Cycles through all the buffs/debuffs, applying their effects as appropriate.
function Pred.Engine:ApplyAllBuffEffects()
    local timeDiff = Pred.Engine:GetPeriod()
    local BuffEffects = Pred.CurrentRuleSet.BuffEffects
    local setup = PLAYER_ENV_SETUP
    local loadstring = Pred:Memoize(loadstring)
    
    -- Apply Player buffs
    for sp in pairs(Player.buffs) do
        if BuffEffects[sp] then
            assert(loadstring(setup .. BuffEffects[sp]))()
            if Options.overlayPrediction then
                Overlay:Append("Applied player buff:" .. sp .. "\n")
            end
        end
        Pred.Engine:AdvanceBuffTimeRemaining("Player", "buffs", sp, timeDiff)
    end

    -- Advance Player debuffs
    for sp in pairs(Player.debuffs) do
        Pred.Engine:AdvanceBuffTimeRemaining("Player", "debuffs", sp, timeDiff)
    end

    -- Advance Target buffs
    for sp in pairs(Target.buffs) do
        Pred.Engine:AdvanceBuffTimeRemaining("Target", "buffs", sp, timeDiff)
    end

    -- Apply Target debuffs
    for sp in pairs(Target.debuffs) do
        if BuffEffects[sp] then
            assert(loadstring(setup .. BuffEffects[sp]))()
            if Options.overlayPrediction then
                Overlay:Append("Applied Target debuff:" .. sp .. "\n")
            end
        end
        Pred.Engine:AdvanceBuffTimeRemaining("Target", "debuffs", sp, timeDiff)
    end
end -- Pred.Engine:ApplyAllBuffEffects(timeDiff) -----------------------------------------------------------------------


-- Cycles through all the regen effects, applying them as appropriate
function Pred.Engine:ApplyAllRegenEffects()
    local RegenEffects = Pred.CurrentRuleSet.RegenEffects
    local setup = PLAYER_ENV_SETUP
    local loadstring = Pred:Memoize(loadstring)
    
    for name, effect in pairs(RegenEffects) do
        if name and effect then
            assert(loadstring(setup .. effect))()
            if Options.overlayPrediction then
                Overlay:Append("Applied Regen:" .. name .. "\n")
            end
        end
    end
end -- Pred.Engine:ApplyAllRegenEffects --------------------------------------------------------------------------------


-- Tells the engine the cast became instant of cast. Invoke GCD instead, and ignore cast effect.
function Pred.Engine:SetInstant()
    Pred.castBecameInstant = true
end -- Pred.Engine:SetInstant ------------------------------------------------------------------------------------------