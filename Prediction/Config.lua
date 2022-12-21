-- Config options

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')
local AC = LibStub('AceConfig-3.0')

------------------------------------------------------------------------------------------------------------------------
--                                                CONFIG OBJECT                                                       --
------------------------------------------------------------------------------------------------------------------------

-- The options this addon supports
Pred.configOptions = {
    name = "Prediction",
    handler = Pred,
    type = 'group',
    args = {
        edit = {
            type = "input",
            name = "Edit",
            desc = "Change user rules|effects for your class and specialization",
            usage = "",
            set = "SetEdit",
        },
        frequency = {
            type = "input",
            name = "Frequency",
            desc = "The frequency (in Hz) Prediction will attempt to run at",
            usage = "<Hertz>",
            get = "GetFrequency",
            set = "SetFrequency",
        },
        overlay = {
            type = "input",
            name = "Overlay",
            desc = "Enable|disable the diagnostic overlay",
            usage = "on|off",
            get = "GetOverlay",
            set = "SetOverlay",
        },
        ooc = {
            type = "input",
            name = "Out Of Combat",
            desc = "Enable|disable helper out-of-combat",
            usage = "on|off",
            get = "GetOOC",
            set = "SetOOC",
        },
        secondBest = {
            type = "input",
            name = "Second Best",
            desc = "Enable|disable display of second-best action",
            usage = "on|off",
            get = "GetSecondBest",
            set = "SetSecondBest",
        },
        latency = {
            type = "input",
            name = "Latency",
            desc = "Configure a latency window for recommendations",
            usage = "<milliseconds>",
            get = "GetLatency",
            set = "SetLatency",
        },
        _dump = {
            type = "input",
            name = "_Dump",
            desc = "Generate debug output",
            usage = "",
            set = "Set_Dump",
        },
    },
}

------------------------------------------------------------------------------------------------------------------------
--                                               CONFIG FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Options = Pred.Options

-- Returns the frequency for the GUI
function Pred:GetFrequency(info)
    Pred:Print("frequency set to " .. Options.frequency)
    return Options.frequency
end -- Pred:GetFrequency(info) -----------------------------------------------------------------------------------------


-- Sets the frequency, if allowable
function Pred:SetFrequency(info, newFrequency)
    Pred:Print("frequency changing from " .. Options.frequency .. " to " .. newFrequency)
    
    -- Safety
    newFrequency = tonumber(newFrequency)
    if newFrequency == nil or newFrequency < PREDICTION_FREQUENCY_MIN or newFrequency > PREDICTION_FREQUENCY_MAX then
        Pred:Print("frequency option " .. tostring(newFrequency) .. " invalid")
        return
    end
    
    Options.frequency = newFrequency
    -- Ensure timer is started/stopped.
    Pred.Timer.UpdateNextCallTime()
end -- Pred:SetFrequency(info, newFrequency) ---------------------------------------------------------------------------


-- Returns the overlay status for the GUI
function Pred:GetOverlay(info)
    Pred:Print("overlay set to " .. Options.overlay)
    return Options.overlay
end -- Pred:GetOverlay(info) -------------------------------------------------------------------------------------------


-- Sets the overlay, if allowable
function Pred:SetOverlay(info, newOverlay)
    Pred:Print("overlay changing from " .. Options.overlay .. " to " .. newOverlay)
    
    -- Safety
    if newOverlay == "+prediction" then
        Options.overlayPrediction = true
    elseif newOverlay == "-prediction" then
        Options.overlayPrediction = false
    elseif newOverlay == '+spells' then
        Options.overlaySpells = true
    elseif newOverlay == '-spells' then
        Options.overlaySpells = false
    elseif newOverlay == 'on' or newOverlay == 'off' then
        Options.overlay = newOverlay
    else
        if newOverlay:sub(2,7) == "spell " then
            local spellName = newOverlay:sub(8)
            if spellName and spellName ~= "" then
                if newOverlay:sub(1,1) == "+" then
                    Options.overlaySpellList[#Options.overlaySpellList + 1] = spellName
                else
                    for i = 1, #Options.overlaySpellList do
                        local found = false
                        if Options.overlaySpellList[i] == spellName then
                            Options.overlaySpellList[i] = Options.overlaySpellList[#Options.overlaySpellList]
                            found = true
                        end
                        if found then
                            Options.overlaySpellList[#Options.overlaySpellList] = nil
                        end
                    end
                end
            end
        else
            Pred:Print("overlay option " .. newOverlay .. " invalid")
        end
    end
end -- Pred:SetOverlay(info, newOverlay) -------------------------------------------------------------------------------


-- Returns the out-of-combat config option
function Pred:GetOOC(info)
    Pred:Print("ooc set to " .. Options.ooc)
    return Options.ooc
end -- Pred:GetOOC(info) -----------------------------------------------------------------------------------------------


-- Sets the out-of-combat option, if allowable
function Pred:SetOOC(info, newOOC)
    Pred:Print("ooc changing from " .. Options.ooc .. " to " .. newOOC)
    
    -- Safety
    if newOOC == 'on' or newOOC == 'off' then
        Options.ooc = newOOC
    else
        Pred:Print("ooc option " .. newOOC .. " invalid")
    end
    
    -- See if the display needs to be updated.
    Pred.GUI:Show()
end -- Pred:SetOOC(info, newOOC) ---------------------------------------------------------------------------------------


-- Returns the secondBest config option
function Pred:GetSecondBest(info)
    Pred:Print("secondBest set to " .. Options.secondBest)
    return Options.secondBest
end -- Pred:GetSecondBest(info) ----------------------------------------------------------------------------------------


-- Sets the secondBest config option, if allowable
function Pred:SetSecondBest(info, newSecondBest)
    Pred:Print("secondBest changing from " .. Options.secondBest .. " to " .. newSecondBest)
    
    -- Safety
    if newSecondBest == 'on' or newSecondBest == 'off' then
        Options.secondBest = newSecondBest
    else
        Pred:Print("secondBest option " .. newSecondBest .. " invalid")
    end

    -- See if the display needs to be updated.
    Pred.GUI:Show()
end -- Pred:SetSecondBest(info, newSecondBest) -------------------------------------------------------------------------


-- Returns the latency for the GUI
function Pred:GetLatency(info)
    Pred:Print("latency set to " .. Options.latency)
    return Options.latency
end -- Pred:GetLatency(info) -------------------------------------------------------------------------------------------


-- Sets the latency, if allowable
function Pred:SetLatency(info, newLatency)
    Pred:Print("latency changing from " .. Options.latency .. " to " .. newLatency)
    
    -- Safety
    newLatency = tonumber(newLatency)
    if newLatency == nil or newLatency < PREDICTION_LATENCY_MIN or newFrequency > PREDICTION_LATENCY_MAX then
        Pred:Print("latency option " .. tostring(newLatency) .. " invalid")
        return
    end
    
    Options.latency = newLatency
end -- Pred:SetLatency(info, newLatency) -------------------------------------------------------------------------------


-- Create a dump of the data contained in Prediction
function Pred:Set_Dump(info, newDump)
    -- TODO: Create dump window.
    Pred:NotYetImplemented("Set_Dump")
end -- Pred:Set_Dump(info, newDump) ------------------------------------------------------------------------------------


-- Opens the UserUI
function Pred:SetEdit(info, newEdit)
    Pred.UI:Show()
end -- Pred:SetEdit(info, newEdit) -------------------------------------------------------------------------------------


-- Registers the config options with Ace3
function Pred:RegisterConfigOptions()
    AC:RegisterOptionsTable("Prediction",function() return Pred.configOptions end, {"prediction",})
end -- Pred:RegisterConfigOptions --------------------------------------------------------------------------------------
