local Utility = {}

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

function Utility.GetDictionaryLength(Dictionary)
    local Count = 0
    local NextIndex = next(Dictionary)

    while true do
        if NextIndex == nil then
            break
        end

        NextIndex = next(Dictionary, NextIndex)

        Count += 1
    end

    return Count
end

function Utility.GetParentProperties(Parent)
    local Size = Vector2.new(1920, 1080)
    local Position = Vector2.new(0, 0)

    if Parent:GetAttribute("FigmaSize") then
        Size = Parent:GetAttribute("FigmaSize")
    end

    if Parent:GetAttribute("FigmaPosition") then
        Position = Parent:GetAttribute("FigmaPosition")
    end

    return Size, Position
end

function Utility.ConvertToContextualScale(Object : Instance, Pixels : Vector2)
    local ParentSize, ParentPosition = Utility.GetParentProperties(Object.Parent)
    local Scale = (Pixels / ParentSize)

    return UDim2.fromScale(Scale.X, Scale.Y)
end

function Utility.ApplyImage(ImageLabel : Instance, Image : string)
    pcall(function()
        Image = Image:gsub("rbxassetid://", "")
        ImageLabel.Image = "rbxassetid://" .. Image
    end)
end

function Utility.GetSelectedItem()
    local Selected = Selection:Get()
    local SelectedItem = Selected[1]

    return SelectedItem
end

function Utility.CreateUndoMarkerStart()
    ChangeHistoryService:SetWaypoint("FigmaAssistantMarkerStart")
end

function Utility.CreateUndoMarkerEnd()
    ChangeHistoryService:SetWaypoint("FigmaAssistantMarkerEnd")
end

return Utility