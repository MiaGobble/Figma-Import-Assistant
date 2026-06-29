local Utility = {}

-- Services
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

function Utility.GetDictionaryLength(dictionary)
    local Count = 0

    for _ in pairs(dictionary) do
        Count += 1
    end

    return Count
end

function Utility.GetParentProperties(parent)
    local Size = Vector2.new(1920, 1080)
    local Position = Vector2.new(0, 0)

    if parent:GetAttribute("FigmaSize") then
        Size = parent:GetAttribute("FigmaSize")
    end

    if parent:GetAttribute("FigmaPosition") then
        Position = parent:GetAttribute("FigmaPosition")
    end

    return Size, Position
end

function Utility.ConvertToContextualScale(object : Instance, pixels : Vector2)
    local ParentSize = Utility.GetParentProperties(object.Parent)
    local Scale = (pixels / ParentSize)

    return UDim2.fromScale(Scale.X, Scale.Y)
end

function Utility.ApplyImage(imageLabel : Instance, image : string)
    pcall(function()
        image = image:gsub("rbxassetid://", "")
        imageLabel.Image = "rbxassetid://" .. image
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