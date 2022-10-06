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

-- Show the Effects tab.
function Pred.UI:SelectSpellEffects(container)
    container:SetLayout("Flow")

    local ddl, del, create, name, save = AceGUI:Create("Dropdown"), AceGUI:Create("Button"), AceGUI:Create("Button"), AceGUI:Create("EditBox"), AceGUI:Create("Button")
    local mlebInstant, mlebCast = AceGUI:Create("MultiLineEditBox"), AceGUI:Create("MultiLineEditBox")

    Pred.UI:SpellEffectListUpdate(ddl)
    ddl:SetCallback("OnValueChanged", function(key, checked) 
        Pred.UI:ChangeSelectedSpellEffect(key['value'], name, mlebInstant, mlebCast)
    end)

    del:SetText("Delete")
    del:SetCallback("OnClick", function()
        Pred.UI:SpellEffectDelete(ddl, name, mlebInstant, mlebCast)
    end)

    create:SetText("New")
    create:SetCallback("OnClick", function()
        Pred.UI:SpellEffectNew(name, mlebInstant, mlebCast)
    end)
    
    name:SetText("")
    name:DisableButton(true)
    
    save:SetText("Save")
    save:SetCallback("OnClick", function()
        Pred.UI:SpellEffectSave(ddl, name, mlebInstant, mlebCast)
    end)

    container:AddChild(ddl)
    container:AddChild(del)
    container:AddChild(create)
    container:AddChild(name)
    container:AddChild(save)
    
    
    mlebInstant:SetLabel("Instant Effect:")
    mlebInstant:SetFullWidth(true)
    mlebInstant:SetNumLines(9)
    mlebInstant:DisableButton(true)
    container:AddChild(mlebInstant)

    mlebCast:SetLabel("Cast Effect:")
    mlebCast:SetFullWidth(true)
    mlebCast:SetNumLines(9)
    mlebCast:DisableButton(true)
    container:AddChild(mlebCast)
    
end -- Pred.UI:SelectSpellEffects(container) ---------------------------------------------------------------------------


-- Update the provided dropdown with the current effects.
function Pred.UI:SpellEffectListUpdate(ddl)
    local effectList, effectListSize = {}, 0
    for k, _ in Pred:OrderedByKeys(Pred.CurrentRuleSet.SpellEffects) do
        effectListSize = effectListSize + 1
        effectList[k] = k
    end
    if effectListSize > 0 then
        ddl:SetList(effectList)
    end
end -- Pred.UI:SpellEffectListUpdate(ddl) ------------------------------------------------------------------------------


-- Updates the MultiLineEditBox to contain the data related to this particular key.
function Pred.UI:ChangeSelectedSpellEffect(key, name, mlebInstant, mlebCast)
    name:SetText(key)
    mlebInstant:SetText(Pred.CurrentRuleSet.SpellEffects[key].Instant)
    mlebCast:SetText(Pred.CurrentRuleSet.SpellEffects[key].Cast)
end -- Pred.UI:ChangeSelectedSpellEffect(key, mlebInstant, mlebCast) ---------------------------------------------------


-- Clears the fields so the user can enter a new one.
function Pred.UI:SpellEffectNew(name, mlebInstant, mlebCast)
    if name and mlebInstant and mlebCast then
        name:SetText("")
        mlebInstant:SetText("")
        mlebCast:SetText("")
    end
end -- Pred.UI:SpellEffectNew(name, mlebInstant, mlebCast) -------------------------------------------------------------


-- Handles the save event. Attempts to validate the user's entry before saving.
function Pred.UI:SpellEffectSave(ddl, name, mlebInstant, mlebCast)
    if ddl and name and mlebInstant and mlebCast then
        local spell = name:GetText()
        local instantEffect = mlebInstant:GetText()
        local castEffect = mlebCast:GetText()
        local setup = PLAYER_ENV_SETUP
        
        if pcall(loadstring(setup .. instantEffect)) and pcall(loadstring(setup .. castEffect)) then
            UI.frame:SetStatusText("Parsed successfully. Applying to database")
            Pred.CurrentRuleSet.SpellEffects[spell] = {
                Instant = instantEffect,
                Cast = castEffect,
            }
            Pred.UI:SpellEffectListUpdate(ddl)
        else
            UI.frame:SetStatusText("Parsing Error: No target selected or syntax error.")
        end
    end
end -- Pred.UI:SpellEffectSave(name, mlebInstant, mlebCast) ------------------------------------------------------------


-- Deletes the currently selected effect, then updates the ddl.
function Pred.UI:SpellEffectDelete(ddl, name, mlebInstant, mlebCast)
    if ddl and name and mlebInstant and mlebCast then
        local spell = name:GetText()
        if name then
            Pred.CurrentRuleSet.SpellEffects[spell] = nil
            Pred.UI:SpellEffectListUpdate(ddl)
        end
    end
end -- Pred.UI:SpellEffectDelete(ddl, name, mlebInstant, mlebCast) -----------------------------------------------------