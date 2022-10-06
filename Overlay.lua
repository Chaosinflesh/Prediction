-- Overlay display

PREDICTION_OVERLAY_STRING = 'Prediction v' .. VERSION .. '\n\n'
PREDICTION_FONT_STRING = 'Interface\\Addons\\Prediction\\Fonts\\FiraMono-Medium.ttf'

--local LibStub = LibStub
local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')
local AC = LibStub('AceConfig-3.0')
local LSM = LibStub('LibSharedMedia-3.0')

------------------------------------------------------------------------------------------------------------------------
--                                               OVERLAY OBJECT                                                       --
------------------------------------------------------------------------------------------------------------------------

Pred.Overlay = {
    frame = nil,    -- Holds a frame for displaying useful output.
}

------------------------------------------------------------------------------------------------------------------------
--                                              OVERLAY FUNCTIONS                                                     --
------------------------------------------------------------------------------------------------------------------------

local Options = Pred.Options
local Overlay = Pred.Overlay

-- Initialize the overlay
function Pred.Overlay:Init()


    -- The font to use
    LSM:Register("font", "PredictionFont", PREDICTION_FONT_STRING)
    local font = LSM:Fetch("font", "PredictionFont")

    -- The frame itself
    Overlay.frame = CreateFrame("Frame", "PredictionOverlay", UIParent)
    local frame = Overlay.frame
    frame:SetWidth(1920)
    frame:SetHeight(1080)
    frame:SetPoint("TOPLEFT",0,0)

    -- It's child text.
    frame.text = Overlay.frame:CreateFontString()
    frame.text:SetFont(font, 12)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetPoint("TOPLEFT", 50, -100)
    frame.text:SetPoint("BOTTOMRIGHT", -10, 10)
    frame.text:SetTextColor(0.8, 0.8, 0.8, 1.0)
    frame.text:SetText(PREDICTION_OVERLAY_STRING)
end -- Pred.Overlay:Init -----------------------------------------------------------------------------------------------


-- Enables the overlay.
function Pred.Overlay:Show()

    -- Only create the overlay once
    if not Overlay.frame then
        Overlay:Init()
    end
    
    if Options.overlay == 'on' then
        Overlay.frame:Show()
        Overlay.frame.text:Show()
    end
end -- Pred.Overlay:Show -----------------------------------------------------------------------------------------------


-- Disables the overlay.
function Pred.Overlay:Hide()
    if Overlay.frame then
        Overlay:Clear()
        Overlay.frame:Hide()
    end
end -- Pred.Overlay:Hide -----------------------------------------------------------------------------------------------


-- Prints the data to the overlay.
function Pred.Overlay:Append(data)
    if data then
        -- Only need to update the overlay if it exists
        if Overlay.frame then
            Overlay.frame.text:SetText(Overlay.frame.text:GetText() .. data)
        end
    end
end -- Pred.Overlay:Append(data) ---------------------------------------------------------------------------------------


-- Blanks out the overlay.
function Pred.Overlay:Clear()
    -- Only need to update the overlay if the config option is set. Ignore the request otherwise.
    if Overlay.frame then
        Overlay.frame.text:SetText(PREDICTION_OVERLAY_STRING)
    end
end -- Pred.Overlay:Clear ----------------------------------------------------------------------------------------------