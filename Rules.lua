-- Contains the definition of the default rules

-- Rules are defined by server-character-spec-talents at the moment
-- See the first example for how rules are defined.


local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

Pred.CurrentRuleSet = nil

------------------------------------------------------------------------------------------------------------------------
--                                                  RULE FUNCTIONS                                                    --
------------------------------------------------------------------------------------------------------------------------

Pred.Rules = {}

local Options = Pred.Options
local Player = Pred.Player
local Target = Pred.Target

-- Will attempt to load the specified ruleset.
function Pred.Rules:ReloadRules()

    local name, class, _, spec = GetUnitName('player'), UnitClass('player'), GetSpecializationInfo(GetSpecialization())
    if not Pred.db.global[name] then
        Pred.db.global[name] = {
            [class] = {
                [spec] = "Default"
            }
        }
    elseif not Pred.db.global[name][class] then
        Pred.db.global[name][class] = {
            [spec] = "Default"
        }
    elseif not Pred.db.global[name][class][spec] then
        Pred.db.global[name][class][spec] = "Default"
    end

    local ruleSet = Pred.db.global[name][class][spec]
    Pred:Print("ruleSet = " .. ruleSet)
    Pred.CurrentRuleSet = Pred.db.global[class][spec][ruleSet]

end -- Pred.Rules:ReloadRules ------------------------------------------------------------------------------------------

-- Print out the rules in a sensible format
function Pred.Rules:Print(o)

    -- Safety
    if not o then
        return
    end
    
    Pred:PrintDebug("Loaded rules for: ")
    for i = 1, #o do
        Pred:PrintDebug(o[i][1] .. "  " .. o[i][2])
    end
end -- Pred.Rules:Print(o) ---------------------------------------------------------------------------------------------


-- Attempt to find the best spell to cast right now,
function Pred.Rules:FindBestSpell(includeSecondBest)

    -- Safety
    if not Pred.CurrentRuleSet then
        Pred.Rules:ReloadRules()
    end

    local loadstring = Pred:Memoize(loadstring)
    local r = Pred.CurrentRuleSet.Rules
    local spellBest, spellSecond = nil, nil
    local setup = PLAYER_ENV_SETUP
    local yes = false;
    
    -- Cycle through each of the current rules, determining if it is possible to execute.
    for i = 1, #r do
        -- First test if we know the spell
        local spell, condition = r[i][1], setup .. "if " .. r[i][2] .. " then return true end"
        if Player.spells[spell] then
            -- Then test if it's off cooldown
            if (Player.spells[spell].currentCharges and Player.spells[spell].currentCharges > 0) or Player.spells[spell].remainingCooldown < Options.latency then
                -- Then test if it meets the specified conditions.
                if assert(loadstring(condition))() then
                    if not spellBest then
                        spellBest = spell
                    elseif includeSecondBest and not spellSecond then
                        spellSecond = spell
                    end
                end
            end
        end
    end
    
    return spellBest, spellSecond
end -- Pred.Rules:FindBestSpell ----------------------------------------------------------------------------------------