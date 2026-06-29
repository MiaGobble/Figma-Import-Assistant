local CorrectionHandler = {}

local SelectionService = game:GetService("Selection")

local Interface = require(script.Parent.Interface)
local Utility = require(script.Parent.Utility)
local AppImportInterpreter = require(script.AppImportInterpreter)
local Creator = require(script.Creator)
local Applicator = require(script.Applicator)
local Converter = require(script.Converter)

local SelectedInstance = nil

function CorrectionHandler:Init()
    Interface.OnApply(function(Data, Selected)
        if Selected then
            Applicator:ApplyChangesFromData(Selected, Data)
        end
    end)

    Interface.OnAutoImport(function(Mode, ImportDataJSON, Selected)
        if not Selected or not Selected:IsA("ScreenGui") then
            warn("Auto import requires a selected ScreenGui")
            return
        end

        local Success, InterpretedData = pcall(function()
            return AppImportInterpreter:InterpretJSONData(ImportDataJSON, Mode)
        end)

        if not Success then
            warn(`Failed to parse import JSON: {InterpretedData}`)
            return
        end

        if InterpretedData and #InterpretedData.Root > 0 then
            Utility.CreateUndoMarkerStart()
            Creator:CreateFromData(Selected, InterpretedData, Mode)
            Utility.CreateUndoMarkerEnd()
        end
    end)

    Interface.OnCreateInstance(function(ClassName, Selected)
        if not Selected or (not Selected:IsA("GuiObject") and not Selected:IsA("ScreenGui")) then
            return
        end

        local NewObject = Instance.new(ClassName)
        NewObject.Name = ClassName
        NewObject.Parent = Selected
        SelectionService:Set({NewObject})
    end)

    Interface.OnConvertInstance(function(TargetClassName, Selected)
        if not Selected then
            return
        end

        Converter:ConvertInstance(Selected, TargetClassName)
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