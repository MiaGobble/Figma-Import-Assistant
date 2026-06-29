local Converter = {}

-- Services
local Selection = game:GetService("Selection")

-- Imports
local Packages = script.Parent.Parent.Parent.Packages
local Seam = require(Packages.Seam)

-- Constants
local COMMON_GUI_OBJECT_PROPERTIES = {
    "Name",
    "LayoutOrder",
    "Size",
    "Position",
    "AnchorPoint",
    "Visible",
    "BackgroundColor3",
    "BackgroundTransparency",
    "BorderColor3",
    "BorderSizePixel",
    "Rotation",
    "ZIndex",
    "ClipsDescendants",
    "AutomaticSize",
}

local IMAGE_PROPERTIES = {
    "Image",
    "ImageRectOffset",
    "ImageRectSize",
    "ImageColor3",
    "ImageTransparency",
    "ScaleType",
    "SliceCenter",
    "SliceScale",
}

local TEXT_PROPERTIES = {
    "Text",
    "TextColor3",
    "TextSize",
    "TextTransparency",
    "TextStrokeColor3",
    "TextStrokeTransparency",
    "TextWrapped",
    "TextScaled",
    "RichText",
    "FontFace",
    "TextXAlignment",
    "TextYAlignment",
}

local function CopyProperties(source : Instance, target : Instance, propertyList : {string})
    for _, PropertyName in ipairs(propertyList) do
        pcall(function()
            target[PropertyName] = source[PropertyName]
        end)
    end
end

function Converter:ConvertInstance(selectedInstance : Instance, targetClassName : string)
    if not selectedInstance or (not selectedInstance:IsA("GuiObject") and not selectedInstance:IsA("ScreenGui")) then
        return nil
    end

    if selectedInstance.ClassName == targetClassName then
        return selectedInstance
    end

    local Parent = selectedInstance.Parent

    if not Parent then
        return nil
    end

    local NewObject = Instance.new(targetClassName)
    NewObject.Parent = Parent

    CopyProperties(selectedInstance, NewObject, COMMON_GUI_OBJECT_PROPERTIES)

    if selectedInstance:IsA("ImageLabel") or selectedInstance:IsA("ImageButton") then
        CopyProperties(selectedInstance, NewObject, IMAGE_PROPERTIES)
    end

    if selectedInstance:IsA("TextLabel") or selectedInstance:IsA("TextButton") or selectedInstance:IsA("TextBox") then
        CopyProperties(selectedInstance, NewObject, TEXT_PROPERTIES)
    end

    local Attributes = selectedInstance:GetAttributes()
    local AttributeCount = 0
    for _ in pairs(Attributes) do
        AttributeCount += 1
    end

    if AttributeCount > 1 then
        for AttributeName, AttributeValue in pairs(Attributes) do
            Seam.Attribute(AttributeName)(NewObject, AttributeValue)
        end
    else
        for AttributeName, AttributeValue in pairs(Attributes) do
            NewObject:SetAttribute(AttributeName, AttributeValue)
        end
    end

    for _, Child in ipairs(selectedInstance:GetChildren()) do
        Child.Parent = NewObject
    end

    selectedInstance:Destroy()
    Selection:Set({NewObject})

    return NewObject
end

return Converter
