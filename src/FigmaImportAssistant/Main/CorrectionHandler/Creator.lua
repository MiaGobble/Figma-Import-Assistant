local Creator = {}

local Applicator = require(script.Parent.Applicator)
local AppImportInterpreter = require(script.Parent.AppImportInterpreter)

local function InterpretActions(Name : string)
    local Actions, NewName = AppImportInterpreter:GetActionsFromName(Name)

    return Actions, NewName
end

local function CreateRecursive(Parent, Data : {})
    for _, Child in Data.Root do
        local Actions, Name = InterpretActions(Child.Name)

        if Actions.Continue then
            continue
        end

        local Object

        for Action, _ in Actions do
            if Action:find("Class") then
                local InstanceType = Action:gsub("Class", "")
                Object = Instance.new(InstanceType)
                break
            end
        end

        if not Object then
            Object = Instance.new(Child.Type)
        end

        Object.ClipsDescendants = if Child.clipsContent ~= nil then Child.clipsContent else true
        Object.BackgroundTransparency = 1
        Object.Parent = Parent
        Object:SetAttribute("IsFigmaImportGroup", Child.IsGroup)
        Child.Name = Name

        Applicator:ApplyChangesFromData(Object, Child)

        if not Actions.BreakAfter and Child.Children then
            CreateRecursive(Object, Child.Children)
        end
    end
end

function Creator:CreateFromData(SelectedInstance, Data : {})
    CreateRecursive(SelectedInstance, Data)
end

return Creator