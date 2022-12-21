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
function Pred.UI:SelectRegenEffects(container)
    container:SetLayout("Flow")

    local ddl, del, create, name, save = AceGUI:Create("Dropdown"), AceGUI:Create("Button"), AceGUI:Create("Button"), AceGUI:Create("EditBox"), AceGUI:Create("Button")
    local mleb = AceGUI:Create("MultiLineEditBox")

    Pred.UI:RegenEffectListUpdate(ddl)
    ddl:SetCallback("OnValueChanged", function(key, checked) 
        Pred.UI:ChangeSelectedRegenEffect(key['value'], name, mleb)
    end)

    del:SetText("Delete")
    del:SetCallback("OnClick", function()
        Pred.UI:RegenEffectDelete(ddl, name, mleb)
    end)

    create:SetText("New")
    create:SetCallback("OnClick", function()
        Pred.UI:RegenEffectNew(name, mleb)
    end)
    
    name:SetText("")
    name:DisableButton(true)
    
    save:SetText("Save")
    save:SetCallback("OnClick", function()
        Pred.UI:RegenEffectSave(ddl, name, mleb)
    end)

    container:AddChild(ddl)
    container:AddChild(del)
    container:AddChild(create)
    container:AddChild(name)
    container:AddChild(save)
    
    
    mleb:SetLabel("Regen Effect:")
    mleb:SetFullWidth(true)
    mleb:SetNumLines(19)
    mleb:DisableButton(true)
    container:AddChild(mleb)

end -- Pred.UI:SelectRegenEffects(container) ---------------------------------------------------------------------------


-- Update the provided dropdown with the current effects.
function Pred.UI:RegenEffectListUpdate(ddl)
    local effectList, effectListSize = {}, 0
    for k, _ in Pred:OrderedByKeys(Pred.CurrentRuleSet.RegenEffects) do
        effectListSize = effectListSize + 1
        effectList[k] = k
    end
    if effectListSize > 0 then
        ddl:SetList(effectList)
    end
end -- Pred.UI:RegenEffectListUpdate(ddl) ------------------------------------------------------------------------------


-- Updates the MultiLineEditBox to contain the data related to this particular key.
function Pred.UI:ChangeSelectedRegenEffect(key, name, mleb)
    name:SetText(key)
    mleb:SetText(Pred.CurrentRuleSet.RegenEffects[key])
end -- Pred.UI:ChangeSelectedRegenEffect(key, mleb) --------------------------------------------------------------------


-- Clears the fields so the user can enter a new one.
function Pred.UI:RegenEffectNew(name, mleb)
    if name and mleb then
        name:SetText("")
        mleb:SetText("")
    end
end -- Pred.UI:RegenEffectNew(name, mleb) ------------------------------------------------------------------------------


-- Handles the save event. Attempts to validate the user's entry before saving.
function Pred.UI:RegenEffectSave(ddl, name, mleb)
    if ddl and name and mleb then
        local spell = name:GetText()
        local buffEffect = mleb:GetText()
        local setup = PLAYER_ENV_SETUP
        
        if pcall(loadstring(setup .. buffEffect)) then
            UI.frame:SetStatusText("Parsed successfully. Applying to database")
            Pred.CurrentRuleSet.RegenEffects[spell] = buffEffect
            Pred.UI:RegenEffectListUpdate(ddl)
        else
            UI.frame:SetStatusText("Parsing Error: No target selected or syntax error.")
        end
    end
end -- Pred.UI:RegenEffectSave(name, mleb) -----------------------------------------------------------------------------


-- Deletes the currently selected buff effect, then updates the ddl.
function Pred.UI:SpellEffectDelete(ddl, name, mleb)
    if ddl and name and mleb then
        local spell = name:GetText()
        if name then
            Pred.CurrentRuleSet.RegenEffects[spell] = nil
            Pred.UI:RegenEffectListUpdate(ddl)
        end
    end
end -- Pred.UI:RegenEffectDelete(ddl, name, mleb) ----------------------------------------------------------------------