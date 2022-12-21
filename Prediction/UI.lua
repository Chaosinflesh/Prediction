-- The User GUI is used to customize the effects and rules the application follows.

-- Rules are defined by server-character-spec-talents at the moment
-- See the first example for how rules are defined.


local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')
local AceGUI = LibStub("AceGUI-3.0")


------------------------------------------------------------------------------------------------------------------------
--                                         CONFIG GUI FUNCTIONS                                                       --
------------------------------------------------------------------------------------------------------------------------

local UI = Pred.UI
local Player = Pred.Player

-- Initialize the GUI.
function Pred.UI:Init()
    if not UI.frame then
        -- Main Frame
        local frame = AceGUI:Create("Frame")
        frame:SetCallback("OnClose", 'Pred.UI:Hide')
        frame:SetTitle("Prediction v" .. VERSION .. ": DB Version" .. Pred.db.global.Version)
        frame:SetLayout("Fill")
        frame:Hide()
        
        -- TabGroup
        local tGroup = AceGUI:Create("TabGroup")
        tGroup:SetLayout("Fill")
        tGroup:SetTabs({
            {value = "rules", text = "Rules"},
            {value = "spellEffects", text = "Spell Effects"},
            {value = "buffEffects", text = "Buff Effects"},
            {value = "regenEffects", text = "Regen Effects"},
            {value = "help", text = "Help"},
        })
        tGroup:SetCallback("OnGroupSelected", function(container, event, tab) Pred.UI:SelectTab(container, event, tab) end)
        tGroup:SelectTab("help")
        frame:AddChild(tGroup)
        
        UI.frame = frame
    end
end -- Pred.UI:Init ---------------------------------------------------------------------------------------------


-- Show the UI
function Pred.UI:Show()
    if not UI.frame then
        UI.Init()
    end
    UI.frame:Show()
end -- Pred.UI:Show ---------------------------------------------------------------------------------------------


-- Hide the UI.
function Pred.UI:Hide()
    if UI.frame then
        UI.frame:Hide()
        UI.frame = nil
    end
end -- Pred.UI:Hide ---------------------------------------------------------------------------------------------


-- Select the tab
function Pred.UI:SelectTab(container, event, tab)
    container:ReleaseChildren()
    if tab == "rules" then
        Pred.UI:SelectRules(container)
    elseif tab == "spellEffects" then
        Pred.UI:SelectSpellEffects(container)
    elseif tab == "buffEffects" then
        Pred.UI:SelectBuffEffects(container)
    elseif tab == "regenEffects" then
        Pred.UI:SelectRegenEffects(container)
    else 
        Pred.UI:SelectHelp(container)
    end
end -- Pred.UI:SelectTab(container, event, tab) -----------------------------------------------------------------


-- Show the Help tab.
function Pred.UI:SelectHelp(container)
    container:SetLayout("Fill")
    local sf = AceGUI:Create("ScrollFrame")
    container:AddChild(sf)
    local desc = AceGUI:Create("Label")
    desc:SetText(Pred.Data.Help)
    desc:SetFullWidth(true)
    sf:AddChild(desc)
end -- Pred.UI:SelectHelp(container) ----------------------------------------------------------------------------