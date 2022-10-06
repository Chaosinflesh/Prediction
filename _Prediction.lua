-- Base module & objects

DEBUG = false
VERBOSE = false
VERSION = "201803131200"
DB_VERSION = "201803131200"

-- Frequency constants, in Hz. 0 effectively disables Prediction
PREDICTION_FREQUENCY_MIN = 0
PREDICTION_FREQUENCY_MAX = 30
PREDICTION_FRAME_TIME = 0.01

-- Latency bounds, in seconds.
PREDICTION_LATENCY_MIN = 0
PREDICTION_LATENCY_MAX = 2

-- Forecast depth. 1 disables prediction beyond immediate state. Hard coded to be 4 atm.
PREDICTION_DEPTH = 4

-- Used to convert those pesky functions that return milliseconds instead of seconds.
MILLIS_TO_SECONDS = 0.001

PLAYER_ENV_SETUP = [[
    local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction');
    local Player, Target, Talents = Pred.Player, Pred.Target, Pred.Player.talents;
    local Procced = function(a)
        return Pred:Procced(a);
    end;
    local UseRunes = function(a)
        Pred.Engine:UseRunes(a);
    end;
    local AddRunes = function(a)
        Pred.Engine:AddRunes(a);
    end;
    local SetInstant = function()
        Pred.Engine:SetInstant();
    end;
    local SetDelayEffect = function(delay, effect)
        Pred.Engine:SetDelayEffect(delay, effect);
    end;
    local GetPeriod = function()
        return Pred.Engine:GetPeriod();
    end;
    local OverrideGCD = function(v)
        Pred.Engine:OverrideGCD(v);
    end;
]]

local Pred = LibStub('AceAddon-3.0'):NewAddon('Prediction','AceConsole-3.0','AceEvent-3.0','AceTimer-3.0')

------------------------------------------------------------------------------------------------------------------------
--                                                 GLOBAL OPTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

Pred.Options = {
    frequency = 16,             -- The frequency for calculations to take place
    overlay = 'off',            -- If the debug overlay is visible or not
    overlaySpells = false,      -- Display the spells as well. Only used for testing.
    overlayPrediction = true,   -- Display the prediction calculations.
    overlaySpellList = {},      -- Display specific spells of interest. Overrides overlaySpells explicitly.
    ooc = 'on',                 -- If the GUI is visible out-of-combat
    secondBest = 'off',         -- If the second-best path is also calculated and displayed
    latency = 0.18,             -- Advances prediction time slightly, to enable better reactions by the player
    size = 80,                  -- The base size of the icons. All icons are scaled from this
    offsetX = 0,                -- Positioning of center of current prediction
    offsetY = -120,             -- Positioning of center of current prediction
    anchorPoint = 'CENTER',     -- Anchor point for whole frame
} -- Pred.Options ------------------------------------------------------------------------------------------------------

Pred.Time = {
    Now = GetTime(), -- No functions should ever call GetTime except the Timer.
    Future = Now,    -- This will be used to determine the time for actions
    lastGCD = Now,   -- Used to determine when the last GCD was
} -- Pred.Time ---------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
--                                          CONFIG GUI OBJECT                                                         --
------------------------------------------------------------------------------------------------------------------------

Pred.db = {
}
Pred.UI = {
}


------------------------------------------------------------------------------------------------------------------------
--                                                BASIC FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------


-- Informs interested parties that function not implemented
function Pred:NotYetImplemented(caller)
    if VERBOSE then
        Pred:Print("Not yet implemented " .. caller)
    end
end -- Pred:NotYetImplemented(caller) ----------------------------------------------------------------------------------


-- Provides debug information to output
function Pred:PrintDebug(message)
    if DEBUG then
        Pred:Print("Prediction [DEBUG]: " .. message)
    end
end -- Pred:PrintDebug(message) ----------------------------------------------------------------------------------------


-- Deep copy. Source was https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function Pred:Clone(obj, seen)
    if type(obj) ~= 'table' then
        return obj
    end
    
    if seen and seen[obj] then
        return seen[obj]
    end

    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do
        res[Pred:Clone(k, s)] = Pred:Clone(v, s)
    end

    return res
end -- Pred:Clone(obj, seen) -------------------------------------------------------------------------------------------


-- Sanitize time.
function Pred:SanitizeTime(millis)
    if millis then
        return millis * MILLIS_TO_SECONDS
    else
        return nil
    end
end -- Pred:SanitizeTime(millis) ---------------------------------------------------------------------------------------


-- Provides an alphabetically sorted table.
function Pred:OrderedByKeys(tbl, sortFunction)
    -- Create shadow table.
    local a = {}
    for n in pairs(tbl) do
        a[#a + 1] = n
    end
    table.sort(a, sortFunction)
    
    local i = 0       -- iterator variable
    return function() -- iterator function
        i = i + 1
        return a[i], tbl[a[i]]
    end -- iter
end -- Pred:OrderedByKeys(tbl, sortFunction) ---------------------------------------------------------------------------


-- Hopefully going to memoize loadstring, since we're getting a substantial performance hit atm.
function Pred:Memoize(f)
    local mem = {} -- memoizing table
    setmetatable(mem, {__mode = "kv"}) -- make it weak
    
    return function (x) -- new version of ’f’, with memoizing
        local r = mem[x]
        if r == nil then -- no previous result?
            r = f(x) -- calls original function
            mem[x] = r -- store result for reuse
        end
        return r
    end
end -- Pred:Memoize(f) -------------------------------------------------------------------------------------------------


-- Simulate the possibility of a proc
function Pred:Procced(chance)
    return math.random() <= chance and true or false
end -- Pred:Procced(chance) --------------------------------------------------------------------------------------------