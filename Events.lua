-- Prediction event handlers

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                                EVENT FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Options = Pred.Options
local Timer = Pred.Timer

-- Gets the players abilities, which are tied to talents, level and gear.
function Pred:RELOAD_PLAYER_PROFILE(eventName, ...)
    -- Reset the GUI
    Pred.Predictions = {}
    Pred.GUI:Clear()
    
    -- Must wait till lock is free.
    Pred.Player:UpdateTalents()
    Pred.Player:GetSpellList()
    Pred.Rules:ReloadRules()
end -- Pred:RELOAD_PLAYER_PROFILE(eventName, ...) ----------------------------------------------------------------------


-- Gets the players gear
function Pred:RELOAD_PLAYER_GEAR(eventName, ...)
    Pred.Player:GetGearList()
end -- Pred:RELOAD_PLAYER_GEAR(eventName, ...) -------------------------------------------------------------------------


-- Runs the engine as required
function Pred:ON_TICK()

    -- Sets the time for all prediction functions to use.
    Pred.Time.Now = GetTime()

    if Timer:IsCallTime() then
        -- Set next calltime before processing to reduce jitter as much as possible.
        Timer:UpdateNextCallTime()
        Pred.Engine:Run()
    end

    -- The GUI animation always gets calculated, every frame.
    Pred.GUI:Animate()

end -- Pred:ON_TICK ----------------------------------------------------------------------------------------------------