local Utility = {}

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
        --Position = Parent:GetAttribute("FigmaPosition")
    end

    -- if Parent.Parent:GetAttribute("FigmaStrokeThickness") then
    --     Size -= Vector2.new(Parent.Parent:GetAttribute("FigmaStrokeThickness"), Parent.Parent:GetAttribute("FigmaStrokeThickness")) * 2
    --     --Position += Vector2.new(Parent:GetAttribute("FigmaStrokeThickness"), Parent:GetAttribute("FigmaStrokeThickness"))
    -- end

    -- if Parent.Parent:GetAttribute("FigmaObliqueSize") then
    --     Size -= Vector2.new(0, Parent:GetAttribute("FigmaObliqueSize"))
    --     --Position += Vector2.new(0, Parent:GetAttribute("FigmaObliqueSize"))
    -- end

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

return Utility