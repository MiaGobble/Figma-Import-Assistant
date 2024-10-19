local Creator = {}

local SIZE_DERITIVATIVE_REF = Vector2.new(1920, 1080)

local Applicator = require(script.Parent.Applicator)
local AppImportInterpreter = require(script.Parent.AppImportInterpreter)

local function InterpretActions(Name : string)
    local Actions, NewName = AppImportInterpreter:GetActionsFromName(Name)

    return Actions, NewName
end

local function GetGuiSizeDerivative(Gui : ScreenGui)
    local Size = Gui:GetAttribute("FigmaSize") or SIZE_DERITIVATIVE_REF
    local Magnitude = (Size / SIZE_DERITIVATIVE_REF).Magnitude

    return Magnitude
end

local function CreateRecursive(Parent, Data : {})
    local Gui = nil

    if Parent:IsA("ScreenGui") then
        Gui = Parent
    else
        Gui = Parent:FindFirstAncestorWhichIsA("ScreenGui")
    end

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

        if Object:IsA("Frame") and Gui:GetAttribute("FigmaSetting_RespectAutoImportFrameOpacity") then
            Object.BackgroundTransparency = 1 - Child.Opacity
            Object.BorderSizePixel = 0
            Object.BackgroundColor3 = Child.Color
        else
            Object.BackgroundTransparency = 1
        end

        if Child.CornerRadius > 0 and Gui:GetAttribute("FigmaSetting_RespectAutoImportCornerRadius") then
            local CornerRadius = Instance.new("UICorner", Object)
            CornerRadius.CornerRadius = UDim.new(0, Child.CornerRadius * GetGuiSizeDerivative(Gui))
        end
        
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