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

-- Show the Rules tab.
function Pred.UI:SelectRules(container)
    container:SetLayout("Flow")
    
    local h1, h2, h3 = AceGUI:Create("Heading"), AceGUI:Create("Heading"), AceGUI:Create("Heading")
    
    local ruleDDL, ruleDel, ruleCreate, ruleName, ruleSelect,ruleCopy = AceGUI:Create("Dropdown"), AceGUI:Create("Button"),
        AceGUI:Create("Button"), AceGUI:Create("EditBox"), AceGUI:Create("Button"), AceGUI:Create("Button")

    local currentRule, currentRuleText = AceGUI:Create("Label"), "NOT SELECTED"
    
    local ddl, del, create, name, moveUp, moveDown, save, mleb = AceGUI:Create("Dropdown"), AceGUI:Create("Button"), AceGUI:Create("Button"),
        AceGUI:Create("EditBox"), AceGUI:Create("Button"), AceGUI:Create("Button"), AceGUI:Create("Button"), AceGUI:Create("MultiLineEditBox")
    
    h2:SetText("Rule Set")
    h2:SetFullWidth(true)
    container:AddChild(h2)

    Pred.UI:RulesUpdate(ruleDDL)
    ruleDDL:SetCallback("OnValueChanged", function(key, checked)
        Pred.UI:ChangeSelectedRuleSet(key['value'], checked, ruleName)
    end)
    container:AddChild(ruleDDL)
    
    ruleDel:SetText("Delete")
    ruleDel:SetCallback("OnClick", function()
        Pred.UI:RuleSetDelete(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    end)
    container:AddChild(ruleDel)
    
    ruleCreate:SetText("New")
    ruleCreate:SetCallback("OnClick", function()
        Pred.UI:RuleSetNew(ruleName)
    end)
    container:AddChild(ruleCreate)
    
    ruleName:DisableButton(true)
    container:AddChild(ruleName)
    
    ruleSelect:SetText("Activate")
    ruleSelect:SetCallback("OnClick", function()
        Pred.UI:RuleSetActivate(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    end)
    container:AddChild(ruleSelect)
    
    ruleCopy:SetText("Copy To")
    ruleCopy:SetCallback("OnClick", function()
        Pred.UI:RuleSetCopy(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    end)
    container:AddChild(ruleCopy)
    
    h1:SetText("Current Rule")
    h1:SetFullWidth(true)
    container:AddChild(h1)
    
    if Pred.db.global[Player.name][Player.class][Player.spec] then
        currentRuleText = Player.class .. " : " .. Player.spec .. " : " .. Pred.db.global[Player.name][Player.class][Player.spec]
    end
    currentRule:SetText(currentRuleText)
    container:AddChild(currentRule)

    h3:SetText("Rules")
    h3:SetFullWidth(true)
    container:AddChild(h3)
    
    Pred.UI:RulesListUpdate(ddl)
    ddl:SetCallback("OnValueChanged", function(key, checked)
        Pred.UI:SelectedRuleChanged(key["value"], name, mleb)
    end)
    container:AddChild(ddl)
    
    del:SetText("Delete")
    del:SetCallback("OnClick", function()
        Pred.UI:RuleDelete(ddl, name, mleb)
    end)
    container:AddChild(del)
    
    create:SetText("New")
    create:SetCallback("OnClick", function()
        Pred.UI:RuleNew(ddl, name, mleb)
    end)
    container:AddChild(create)
    
    name:DisableButton(true)
    container:AddChild(name)
    
    moveUp:SetText("Move Up")
    moveUp:SetCallback("OnClick", function()
        Pred.UI:RuleMoveUp(ddl)
    end)
    container:AddChild(moveUp)
    
    moveDown:SetText("Move Down")
    moveDown:SetCallback("OnClick", function()
        Pred.UI:RuleMoveDown(ddl)
    end)
    container:AddChild(moveDown)
    
    save:SetText("Save")
    save:SetCallback("OnClick", function()
        Pred.UI:RuleSave(ddl, name, mleb)
    end)
    container:AddChild(save)
    
    mleb:SetLabel("Condition (must return TRUE or FALSE):")
    mleb:SetFullWidth(true)
    mleb:SetFullHeight(true)
    mleb:DisableButton(true)
    container:AddChild(mleb)

end -- Pred.UI:SelectRules(container) ---------------------------------------------------------------------------


-- Update the dropdown list with the different rulesets available to this class.
function Pred.UI:RulesUpdate(ruleDDL)
    
    if ruleDDL and Pred.db.global[Player.class][Player.spec] then
        local ruleSets = {}
        for k, _ in pairs(Pred.db.global[Player.class][Player.spec]) do
            if k ~= "HastedCooldowns" then
                ruleSets[k] = k
            end
        end
        ruleDDL:SetList(ruleSets)
    end
end -- Pred.UI:RulesUpdate(ruleDDL) -----------------------------------------------------------------------------


-- Update the provided tree with the current priorities
function Pred.UI:RulesListUpdate(ddl)
    if ddl and #Pred.CurrentRuleSet.Rules > 0 then
        local rulesList = {}
        for i = 1, #Pred.CurrentRuleSet.Rules do
            local r = Pred.CurrentRuleSet.Rules[i]
            rulesList[i] = tostring(i) .. " - " .. r[1]
        end
        ddl:SetList(rulesList)
    end
end -- Pred.UI:RulesListUpdate(tree) ----------------------------------------------------------------------------


-- Changes the selected ruleset. Change not actually applied until 'Activate''d
function Pred.UI:ChangeSelectedRuleSet(key, checked, ruleName)
    if key and ruleName then
        ruleName:SetText(key)
    end
end -- Pred.UI:ChangeSelectedRuleSet(key, checked, ruleName) ----------------------------------------------------


-- Delete the specified ruleset.
function Pred.UI:RuleSetDelete(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    if ruleName and ruleDDL and currentRule and ddl and name and mleb then
        local rule = ruleName:GetText()
        if rule == "Default" then
            UI.frame:SetStatusText("Cannot delete default rule")
            return
        end
        if string.len(rule) > 0 then
            -- Delete the ruleset if it exists
            if Pred.db.global[Player.class][Player.spec][rule] then
                Pred.db.global[Player.class][Player.spec][rule] = nil
            end
            rule = "Default"
            if Pred.db.global[Player.class][Player.spec][rule] then
                Pred.db.global[Player.name][Player.class][Player.spec] = rule
                Pred.Rules:ReloadRules()
                currentRule:SetText(Player.class .. " : " .. Player.spec .. " : " .. Pred.db.global[Player.name][Player.class][Player.spec])
                name:SetText("")
                mleb:SetText("")
                Pred.UI:RulesUpdate(ruleDDL)
                Pred.UI:RulesListUpdate(ddl)
            end
        end
    end
end -- Pred.UI:RuleSetDelete(ruleName, ruleDDL, currentRule, ddl, name, mleb) -----------------------------------


-- Create a new ruleset
function Pred.UI:RuleSetNew(ruleName)
    if ruleName then
        ruleName:SetText("")
    end
end -- Pred.UI:RuleSetNew(ruleName) -----------------------------------------------------------------------------


-- Sets the new rule.
function Pred.UI:RuleSetActivate(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    if ruleName and ruleDDL and currentRule and ddl and name and mleb then
        local rule = ruleName:GetText()
        if string.len(rule) > 0 then
            -- Create the ruleset if it doesn't exist.
            if not Pred.db.global[Player.class][Player.spec][rule] then
                Pred.db.global[Player.class][Player.spec][rule] = Pred:Clone(Pred.Data["Empty RuleSet"])
            end
            if Pred.db.global[Player.class][Player.spec][rule] then
                Pred.db.global[Player.name][Player.class][Player.spec] = rule
                currentRule:SetText(Player.class .. " : " .. Player.spec .. " : " .. Pred.db.global[Player.name][Player.class][Player.spec])
                name:SetText("")
                mleb:SetText("")
                Pred.Rules:ReloadRules()
                Pred.UI:RulesUpdate(ruleDDL)
                Pred.UI:RulesListUpdate(ddl)
            end
        end
    end
end -- Pred.UI:RuleSetActivate(ruleName, ruleDDL, currentRule, ddl, name, mleb) ---------------------------------


-- Update the GUI elements related to editing this spell
function Pred.UI:SelectedRuleChanged(key, name, mleb)
    if key and name and mleb then
        local rules = Pred.CurrentRuleSet.Rules
        name:SetText(rules[key][1])
        mleb:SetText(rules[key][2])
    end
end -- Pred.UI:SelectedRuleChanged(key["value"], name, mleb) ----------------------------------------------------


-- Add a new function with a default name
function Pred.UI:RuleNew(ddl, name, mleb)
    if ddl and name and mleb then
        local rules = Pred.CurrentRuleSet.Rules
        local index = #rules + 1
        rules[index] = {"Auto Attack", "(true)"}
        Pred.Rules:ReloadRules()
        Pred.UI:RulesListUpdate(ddl)
        ddl:SetValue(index)
        name:SetText(rules[index][1])
        mleb:SetText(rules[index][2])
    end
end -- Pred.UI:RuleNew(ddl, name, mleb) -------------------------------------------------------------------------


-- Save the current data into the selected rule spot.
function Pred.UI:RuleSave(ddl, name, mleb)
    if ddl and name and mleb then
        local rule = mleb:GetText()
        if string.len(rule) > 0 then
            local setup = PLAYER_ENV_SETUP
            if pcall(loadstring(setup .. "if " .. rule .. " then end")) then
                UI.frame:SetStatusText("Parsed successfully. Applying to database")
                local rules = Pred.CurrentRuleSet.Rules
                local index = ddl:GetValue()
                rules[index] = { name:GetText(), rule }
                Pred.Rules:ReloadRules()
                Pred.UI:RulesListUpdate(ddl)
                ddl:SetValue(index)
            else
                UI.frame:SetStatusText("Parsing Error: No target selected or syntax error.")
            end
        end
    end
end -- Pred.UI:RuleSave(ddl, name, mleb) ------------------------------------------------------------------------


-- Move the specified spell up in priority
function Pred.UI:RuleMoveUp(ddl)
    if ddl then
        local index = ddl:GetValue()
        if index > 1 then
            local rules = Pred.CurrentRuleSet.Rules
            local temp = rules[index - 1]
            rules[index - 1] = rules[index]
            rules[index] = temp
            Pred.Rules:ReloadRules()
            Pred.UI:RulesListUpdate(ddl)
            ddl:SetValue(index - 1)
        end
    end
end -- Pred.UI:RuleMoveUp(ddl) ----------------------------------------------------------------------------------


-- Move the specified spell down in priority
function Pred.UI:RuleMoveDown(ddl)
    if ddl then
        local index = ddl:GetValue()
        local rules = Pred.CurrentRuleSet.Rules
        if index < #rules then
            local temp = rules[index + 1]
            rules[index + 1] = rules[index]
            rules[index] = temp
            Pred.Rules:ReloadRules()
            Pred.UI:RulesListUpdate(ddl)
            ddl:SetValue(index + 1)
        end
    end
end -- Pred.UI:RuleMoveDown(ddl) --------------------------------------------------------------------------------


-- Delete the ability at the specified location
function Pred.UI:RuleDelete(ddl, name, mleb)
    if ddl and name and mleb then
        local index = ddl:GetValue()
        local rules = Pred.CurrentRuleSet.Rules
        if #rules == 1 then
            UI.frame:SetStatusText("Cannot delete final rule")
            return
        end
        if index >= 1 and index <= #rules then
            for i = index, #rules - 1 do
                rules[i] = rules[i + 1]
            end
        end
        rules[#rules] = nil
        if index > #rules then
            index = #rules
        end
        
        Pred.Rules:ReloadRules()
        Pred.UI:RulesListUpdate(ddl)
        ddl:SetValue(index)
        name:SetText(rules[index][1])
        mleb:SetText(rules[index][2])
    end
end -- Pred.Config:RuleDelete(ddl, name, mleb) -------------------------------------------------------------------------


-- Copy the ruleset (from the DDL) to a new ruleset (from ruleName)
function Pred.UI:RuleSetCopy(ruleName, ruleDDL, currentRule, ddl, name, mleb)
    if ruleName and ruleDDL and currentRule and ddl and name and mleb then
        -- Safety
        local newRuleSet = ruleName:GetText()
        local oldRuleSet = ruleDDL:GetValue()
        
        if newRuleSet == "" or newRuleSet == "default" then
            UI.frame:SetStatusText("Cannot copy to nil or default RuleSet")
        end
        if oldRuleSet == nil or oldRuleSet == "" then
            UI.frame:SetStatusText("No copy source selected")
        end
        
        local rules = Pred.db.global[Player.class][Player.spec]
        rules[newRuleSet] = Pred:Clone(rules[oldRuleSet])
        Pred.UI:RulesUpdate(ruleDDL)
        
        UI.frame:SetStatusText("copied from " .. oldRuleSet .. " to " .. newRuleSet)
    end
end -- Pred.UI:RuleSetCopy(ruleName, ruleDDL, currentRule, ddl, name, mleb) -------------------------------------