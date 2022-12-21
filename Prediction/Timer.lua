-- Timer for Prediction/GUI updates.

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

------------------------------------------------------------------------------------------------------------------------
--                                                 TIMER OBJECT                                                       --
------------------------------------------------------------------------------------------------------------------------

Pred.Timer = {
    
    nextCallTime = nil,  -- The time to check. nil indicates never run
    locked = false,      -- Are we still running (in case of frame overlap, which hopefully won't happen in any case)
    timerId = nil,       -- Holds the timer ID so that we can stop it
    
} -- Pred.Timer --------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
--                                                TIMER FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Options = Pred.Options
local Timer = Pred.Timer


-- Check if it is time to run or not
function Pred.Timer:IsCallTime()
    if Timer.nextCallTime == nil or GetTime() < Timer.nextCallTime then
        return false
    else
        return true
    end
end -- Pred.Timer:IsCallTime -------------------------------------------------------------------------------------------


-- Update the time to check, using configOptions. Can also be used to invoke starting the timer.
function Pred.Timer:UpdateNextCallTime()
    if (Options.frequency == 0) then
        Timer.nextCallTime = nil
    else
        Timer.nextCallTime = GetTime() + 1.0 / Options.frequency
    end
end -- Pred.Timer:UpdateNextCallTime -----------------------------------------------------------------------------------


-- Start the timer
function Pred.Timer:Start()
    Pred.Timer:UpdateNextCallTime()
    Timer.timerId = Pred:ScheduleRepeatingTimer('ON_TICK', 0.01)
end -- Pred.Timer:Start ------------------------------------------------------------------------------------------------


-- Stop the timer
function Pred.Timer:Stop()
    if Timer.timerId ~= nil then
        Pred:CancelTimer(timerId)
    end
    Timer.timerId = nil
end -- Pred.Timer:Stop -------------------------------------------------------------------------------------------------
