local CorrectionHandler = {}

-- Services
local SelectionService = game:GetService("Selection")

-- Imports
local Interface = require(script.Parent.Interface)
local Utility = require(script.Parent.Utility)
local AppImportInterpreter = require(script.AppImportInterpreter)
local Creator = require(script.Creator)
local Applicator = require(script.Applicator)
local Converter = require(script.Converter)

-- Variables
local SelectedInstance = nil

function CorrectionHandler:Init()
    Interface.OnApply(function(data, selected)
        if selected then
            Applicator:ApplyChangesFromData(selected, data)
        end
    end)

    Interface.OnAutoImport(function(modeOrImportDataJSON, importDataJSONOrSelected, selectedMaybe)
        local mode = nil
        local importDataJSON = nil
        local selected = nil

        if selectedMaybe ~= nil then
            mode = modeOrImportDataJSON
            importDataJSON = importDataJSONOrSelected
            selected = selectedMaybe
        else
            importDataJSON = modeOrImportDataJSON
            selected = importDataJSONOrSelected
        end

        if not selected or not selected:IsA("ScreenGui") then
            warn("Auto import requires a selected ScreenGui")
            return
        end

        local Success, InterpretedData = pcall(function()
            return AppImportInterpreter:InterpretJSONData(importDataJSON, mode)
        end)

        if not Success then
            warn(`Failed to parse import JSON: {InterpretedData}`)
            return
        end

        if InterpretedData and #InterpretedData.Root > 0 then
            Utility.CreateUndoMarkerStart()
            Creator:CreateFromData(selected, InterpretedData, InterpretedData.Mode or mode)
            Utility.CreateUndoMarkerEnd()
        end
    end)

    Interface.OnCreateInstance(function(className, selected)
        if not selected or (not selected:IsA("GuiObject") and not selected:IsA("ScreenGui")) then
            return
        end

        local NewObject = Instance.new(className)
        NewObject.Name = className
        NewObject.Parent = selected
        SelectionService:Set({NewObject})
    end)

    Interface.OnConvertInstance(function(targetClassName, selected)
        if not selected then
            return
        end

        Converter:ConvertInstance(selected, targetClassName)
    end)

    SelectionService.SelectionChanged:Connect(function()
        local Selected = SelectionService:Get()
        local SelectedCount = Utility.GetDictionaryLength(Selected)

        if SelectedCount == 1 then
            SelectedInstance = Selected[1]
        else
            SelectedInstance = nil
        end

        if SelectedInstance and not SelectedInstance:IsA("GuiObject") and not SelectedInstance:IsA("ScreenGui") then
            SelectedInstance = nil
        end
        
        Interface.OnSelection(SelectedInstance)
    end)
end

return CorrectionHandler