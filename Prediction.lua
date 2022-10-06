-- Prediction is intended to make intelligent choices about future spellcasts. ATM all it does is print out debug info.

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

function Pred:OnInitialize()
    local defaults = {
        global = {
        }
    }
    
    Pred.db = LibStub("AceDB-3.0"):New("PredictionDB", defaults, 'global')
    
    -- If DB version is too old (for the 12 people who've downloaded the addon at this point, wipe it.
    if Pred.db.global.Version and Pred.db.global.Version < "201803122359" then
        Pred.db:ResetDB('global')
    end
    
    -- Check if we have new defaults
    if (not Pred.db.global.Version) or Pred.db.global.Version < DB_VERSION then
        Pred:Print("Upgrading DB to " .. DB_VERSION)

        -- This will override all defaults. User entries will be preserved.
        Pred:OverrideDefaultDB()
        Pred.db.global.Version = DB_VERSION
    end
    
    Pred:RegisterConfigOptions()
    Pred:PrintDebug("Prediction v" .. VERSION .. " initialized")
end

function Pred:OnEnable()

    -- Initialize the gear
    Pred.Rules:ReloadRules()
    Pred.Player:UpdateTalents()
    Pred.Player:GetGearList()
    
    -- Enable overlay if required
    Pred.Overlay:Show()
    -- Start the timer
    Pred.Timer.Start()
    -- Initialise the GUI
    Pred.GUI:Init()
    
    Pred:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'RELOAD_PLAYER_GEAR')
    Pred:RegisterEvent('SPELLS_CHANGED', 'RELOAD_PLAYER_PROFILE')
    Pred:RegisterEvent('PLAYER_LEVEL_UP', 'RELOAD_PLAYER_PROFILE')

    Pred:PrintDebug("Prediction v" .. VERSION .. " enabled")
    if Pred.db.global then
        Pred:Print("Database version " .. Pred.db.global.Version .. " loaded")
    end
end

function Pred:OnDisable()

    Pred:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
    Pred:UnregisterEvent('SPELLS_CHANGED')
    Pred:UnregisterEvent('PLAYER_LEVEL_UP')

    -- Remove the GUI
    Pred.UI:Hide()
    Pred.GUI:Hide()
    -- Stop the timer
    Pred.Timer.Stop()
    -- Remove the overlay
    Pred.Overlay:Hide()
    
    Pred:PrintDebug("Prediction v" .. VERSION .. " disabled")
end


-- Overrides default rules, effects. etc. HastedCooldowns is always referenced from the addon.
function Pred:OverrideDefaultDB()
    if not Pred.db.global["Death Knight"] then
        Pred.db.global["Death Knight"] = Pred.Data["Death Knight"]
    else
        Pred.db.global["Death Knight"]["Blood"]["Default"] = Pred.Data["Death Knight"]["Blood"]["Default"]
        Pred.db.global["Death Knight"]["Frost"]["Default"] = Pred.Data["Death Knight"]["Frost"]["Default"]
        Pred.db.global["Death Knight"]["Unholy"]["Default"] = Pred.Data["Death Knight"]["Unholy"]["Default"]
    end
    if not Pred.db.global["Demon Hunter"] then
        Pred.db.global["Demon Hunter"] = Pred.Data["Demon Hunter"]
    else
        Pred.db.global["Demon Hunter"]["Havoc"]["Default"] = Pred.Data["Demon Hunter"]["Havoc"]["Default"]
        Pred.db.global["Demon Hunter"]["Vengeance"]["Default"] = Pred.Data["Demon Hunter"]["Vengeance"]["Default"]
    end
    if not Pred.db.global["Druid"] then
        Pred.db.global["Druid"] = Pred.Data["Druid"]
    else
        Pred.db.global["Druid"]["Balance"]["Default"] = Pred.Data["Druid"]["Balance"]["Default"]
        Pred.db.global["Druid"]["Feral"]["Default"] = Pred.Data["Druid"]["Feral"]["Default"]
        Pred.db.global["Druid"]["Guardian"]["Default"] = Pred.Data["Druid"]["Guardian"]["Default"]
        Pred.db.global["Druid"]["Restoration"]["Default"] = Pred.Data["Druid"]["Restoration"]["Default"]
    end
    if not Pred.db.global["Hunter"] then
        Pred.db.global["Hunter"] = Pred.Data["Hunter"]
    else
        Pred.db.global["Hunter"]["Beast Mastery"]["Default"] = Pred.Data["Hunter"]["Beast Mastery"]["Default"]
        Pred.db.global["Hunter"]["Marksmanship"]["Default"] = Pred.Data["Hunter"]["Marksmanship"]["Default"]
        Pred.db.global["Hunter"]["Survival"]["Default"] = Pred.Data["Hunter"]["Survival"]["Default"]
    end
    if not Pred.db.global["Mage"] then
        Pred.db.global["Mage"] = Pred.Data["Mage"]
    else
        Pred.db.global["Mage"]["Arcane"]["Default"] = Pred.Data["Mage"]["Arcane"]["Default"]
        Pred.db.global["Mage"]["Fire"]["Default"] = Pred.Data["Mage"]["Fire"]["Default"]
        Pred.db.global["Mage"]["Frost"]["Default"] = Pred.Data["Mage"]["Frost"]["Default"]
    end
    if not Pred.db.global["Monk"] then
        Pred.db.global["Monk"] = Pred.Data["Monk"]
    else
        Pred.db.global["Monk"]["Brewmaster"]["Default"] = Pred.Data["Monk"]["Brewmaster"]["Default"]
        Pred.db.global["Monk"]["Mistweaver"]["Default"] = Pred.Data["Monk"]["Mistweaver"]["Default"]
        Pred.db.global["Monk"]["Windwalker"]["Default"] = Pred.Data["Monk"]["Windwalker"]["Default"]
    end
    if not Pred.db.global["Paladin"] then
        Pred.db.global["Paladin"] = Pred.Data["Paladin"]
    else
        Pred.db.global["Paladin"]["Holy"]["Default"] = Pred.Data["Paladin"]["Holy"]["Default"]
        Pred.db.global["Paladin"]["Protection"]["Default"] = Pred.Data["Paladin"]["Protection"]["Default"]
        Pred.db.global["Paladin"]["Retribution"]["Default"] = Pred.Data["Paladin"]["Retribution"]["Default"]
    end
    if not Pred.db.global["Priest"] then
        Pred.db.global["Priest"] = Pred.Data["Priest"]
    else
        Pred.db.global["Priest"]["Discipline"]["Default"] = Pred.Data["Priest"]["Discipline"]["Default"]
        Pred.db.global["Priest"]["Holy"]["Default"] = Pred.Data["Priest"]["Holy"]["Default"]
        Pred.db.global["Priest"]["Shadow"]["Default"] = Pred.Data["Priest"]["Shadow"]["Default"]
    end
    if not Pred.db.global["Rogue"] then
        Pred.db.global["Rogue"] = Pred.Data["Rogue"]
    else
        Pred.db.global["Rogue"]["Assassination"]["Default"] = Pred.Data["Rogue"]["Assassination"]["Default"]
        Pred.db.global["Rogue"]["Outlaw"]["Default"] = Pred.Data["Rogue"]["Outlaw"]["Default"]
        Pred.db.global["Rogue"]["Subtlety"]["Default"] = Pred.Data["Rogue"]["Subtlety"]["Default"]
    end
    if not Pred.db.global["Shaman"] then
        Pred.db.global["Shaman"] = Pred.Data["Shaman"]
    else
        Pred.db.global["Shaman"]["Elemental"]["Default"] = Pred.Data["Shaman"]["Elemental"]["Default"]
        Pred.db.global["Shaman"]["Enhancement"]["Default"] = Pred.Data["Shaman"]["Enhancement"]["Default"]
        Pred.db.global["Shaman"]["Restoration"]["Default"] = Pred.Data["Shaman"]["Restoration"]["Default"]
    end
    if not Pred.db.global["Warlock"] then
        Pred.db.global["Warlock"] = Pred.Data["Warlock"]
    else
        Pred.db.global["Warlock"]["Affliction"]["Default"] = Pred.Data["Warlock"]["Affliction"]["Default"]
        Pred.db.global["Warlock"]["Demonology"]["Default"] = Pred.Data["Warlock"]["Demonology"]["Default"]
        Pred.db.global["Warlock"]["Destruction"]["Default"] = Pred.Data["Warlock"]["Destruction"]["Default"]
    end
    if not Pred.db.global["Warrior"] then
        Pred.db.global["Warrior"] = Pred.Data["Warrior"]
    else
        Pred.db.global["Warrior"]["Arms"]["Default"] = Pred.Data["Warrior"]["Arms"]["Default"]
        Pred.db.global["Warrior"]["Fury"]["Default"] = Pred.Data["Warrior"]["Fury"]["Default"]
        Pred.db.global["Warrior"]["Protection"]["Default"] = Pred.Data["Warrior"]["Protection"]["Default"]
    end
end -- Pred:OverrideDefaultDB() ----------------------------------------------------------------------------------------