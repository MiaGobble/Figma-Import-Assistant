local CorrectionHandler = {}

local SelectionService = game:GetService("Selection")

local Interface = require(script.Parent.Interface)
local Utility = require(script.Parent.Utility)
local AppImportInterpreter = require(script.AppImportInterpreter)
local Creator = require(script.Creator)
local Applicator = require(script.Applicator)

local SelectedInstance = nil

function CorrectionHandler:Init()
    Interface:OnApply(function(Data)
        if SelectedInstance then
            Applicator:ApplyChangesFromData(SelectedInstance, Data)
        end
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
        
        Interface:OnSelection(SelectedInstance)
    end)
end

function CorrectionHandler:BuildFromImportData(ImportDataJSON : string)
    local InterpretedData = AppImportInterpreter:InterpretJSONData(ImportDataJSON)

    if InterpretedData and #InterpretedData > 0 then
        Creator:CreateFromData(InterpretedData)
    end
end

return CorrectionHandler