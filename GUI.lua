-- GUI display

PREDICTION_GUI_DEFAULT_ICON = 'Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp'

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')
local AC = LibStub('AceConfig-3.0')

------------------------------------------------------------------------------------------------------------------------
--                                                 GUI OBJECT                                                         --
------------------------------------------------------------------------------------------------------------------------

-- Contains all the data for the prediction GUI
Pred.GUI = {
    frame = nil,
    icons = {},     -- Will hold 8 icons only (at this stage)
    iconSide = 80,  -- Used to calculate GUI size, etc.
    lastGCD = 0,    -- There is an issue with casts after GCDs.
}

------------------------------------------------------------------------------------------------------------------------
--                                                GUI FUNCTIONS                                                       --
------------------------------------------------------------------------------------------------------------------------

local Player = Pred.Player
local GUI = Pred.GUI
local Options = Pred.Options
local icons = Pred.GUI.icons
local iconSide = Pred.GUI.iconSide
local BASE_SIDE = Pred.Options.size
local BASE_X = Pred.Options.offsetX
local BASE_Y = Pred.Options.offsetY
local BASE_ANCHOR = Pred.Options.anchorPoint

-- Initialise the GUI
function Pred.GUI:Init()
    GUI.frame = CreateFrame("Frame", "PredictionGUI", UIParent)

    -- The frame itself
    GUI.frame:ClearAllPoints()
    GUI.frame:SetWidth(iconSide * 8)
    GUI.frame:SetHeight(iconSide * 2)
    GUI.frame:SetPoint(BASE_ANCHOR, BASE_X, BASE_Y)

    -- It's child icons - Note, these are going to be modified by the AnimateGUI. 0 is second best
    for i = 0, 4 do
        icons[i] = CreateFrame("Frame", "PredictionGUIp" .. tostring(i), GUI.frame)
        icons[i]:ClearAllPoints()
        icons[i]:SetWidth(iconSide)
        icons[i]:SetHeight(iconSide)
        icons[i]:SetPoint("CENTER", -iconSide / 2, -iconSide / 2)
        icons[i].iconPath = PREDICTION_GUI_DEFAULT_ICON
        icons[i]:Show()
    end
    
    Pred.GUI:Hide()
end -- Pred.GUI:Init ---------------------------------------------------------------------------------------------------


-- Enables the GUI.
function Pred.GUI:Show()

    -- Only create the GUI once
    if not GUI.frame then
        GUI:Init()
    end

    -- Check if we're just hiding the GUI and leaving.
    if (Options.ooc == 'off' and (not UnitAffectingCombat('player'))) or (not UnitExists('target') or (UnitIsFriend('player','target'))) then
        GUI:Hide()
        return
    end
    
    -- Update the textures here
    local i
    for i = 0, 4 do
        -- Textures will be set to nil when the iconPath changes.
        if not icons[i].texture then 
            local t = icons[i]:CreateTexture(nil,"BACKGROUND")
            t:SetAllPoints(icons[i])
            icons[i].texture = t
        end
        if icons[i].iconPath then
            icons[i].texture:SetTexture(icons[i].iconPath)
        end
    end
            
    -- Check for 2nd best
    if Options.secondBest == 'on' then
        icons[0]:Show()
    else
        icons[0]:Hide()
    end

    GUI.frame:Show()
end -- Pred.GUI:Show ---------------------------------------------------------------------------------------------------


-- Clears the GUI (happens when switching spec|gear)
function Pred.GUI:Clear()
    for i = 0, 4 do
        if icons[i] then
            icons[1].iconPath = nil
        end
    end
end -- Pred.GUI:Clear --------------------------------------------------------------------------------------------------


-- Disables the GUI.
function Pred.GUI:Hide()
    if GUI.frame then
        GUI.frame:Hide()
    end
end -- Pred.GUI:Hide ---------------------------------------------------------------------------------------------------


-- Displays the icons in the GUI. Needs to ensure GUI is hidden ooc if specified. spells should be a list of spell names.
function Pred.GUI:Update(spellNames)
    
    -- Update icons (if provided); NB: Currently mapping 5->0 for secondBest
    if spellNames then
        for i = 1, 5 do
            if spellNames[i % 5] then
                -- Reset texture if appropriate
                if icons[i % 5].iconPath ~= Player.spells[spellNames[i % 5]].icon then
                    icons[i % 5].iconPath = Player.spells[spellNames[i % 5]].icon
                end 
            else
                icons[i % 5].iconPath = nil
            end
        end
    end
    
end -- Pred.GUI:Update -------------------------------------------------------------------------------------------------


-- Calculate the position of the icon based on it's percent.
-- Percent is 0 - 1, with 1 being right now, 0 being in the future.
function Pred.GUI:CalculateX(percent)
    return 4 * ((1 - percent) * iconSide) * 0.875   -- TODO: Fix the math so it's better.
end -- Pred.GUI:CalculateX(percent) ------------------------------------------------------------------------------------


-- Static positioning of the GUI
function Pred.GUI:AnimateIcons(percent)
    local size      -- Used to change icon sizes by percentages.
    local position  -- Used to change percentages as they scale.
    
    -- Transform percent from cast time into gfx offsets.
    percent = percent / 4

    -- 100%
    position = 0.75 + percent  ; size = position * iconSide
    icons[1]:SetPoint('CENTER', GUI:CalculateX(position), 0)         ; icons[1]:SetWidth(size)   ; icons[1]:SetHeight(size)
    icons[0]:SetPoint('CENTER', GUI:CalculateX(position), -size * 0.875)
    -- 75%
    position = 0.5 + percent   ; size = position * iconSide
    icons[2]:SetPoint('CENTER', GUI:CalculateX(position), 0)         ; icons[2]:SetWidth(size)   ; icons[2]:SetHeight(size)
    icons[0]:SetWidth(size) ; icons[0]:SetHeight(size)
    -- 50%
    position = 0.25 + percent  ; size = position * iconSide
    icons[3]:SetPoint('CENTER', GUI:CalculateX(position), 0)         ; icons[3]:SetWidth(size)   ; icons[3]:SetHeight(size)
    -- 25%
    position = percent         ; size = position * iconSide
    icons[4]:SetPoint('CENTER', GUI:CalculateX(position), 0)         ; icons[4]:SetWidth(size)   ; icons[4]:SetHeight(size)
    
end -- Pred.GUI:AnimateIcons -------------------------------------------------------------------------------------------


-- Creates the animation of the GUI
function Pred.GUI:Animate()
    
    -- Used for positioning information
    local percent = Pred.Player:GetCurrentCast()
    
    -- Redraw the GUI.
    GUI:AnimateIcons(percent)
    GUI:Show()
    
end -- Pred.GUI:Animate ------------------------------------------------------------------------------------------------