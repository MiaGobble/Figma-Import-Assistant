local Converter = {}

local Selection = game:GetService("Selection")
local Packages = script.Parent.Parent.Parent.Packages
local Seam = require(Packages.Seam)

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

local function CopyProperties(Source : Instance, Target : Instance, PropertyList : {string})
    for _, PropertyName in ipairs(PropertyList) do
        pcall(function()
            Target[PropertyName] = Source[PropertyName]
        end)
    end
end

function Converter:ConvertInstance(SelectedInstance : Instance, TargetClassName : string)
    if not SelectedInstance or (not SelectedInstance:IsA("GuiObject") and not SelectedInstance:IsA("ScreenGui")) then
        return nil
    end

    if SelectedInstance.ClassName == TargetClassName then
        return SelectedInstance
    end

    local Parent = SelectedInstance.Parent

    if not Parent then
        return nil
    end

    local NewObject = Instance.new(TargetClassName)
    NewObject.Parent = Parent

    CopyProperties(SelectedInstance, NewObject, COMMON_GUI_OBJECT_PROPERTIES)

    if SelectedInstance:IsA("ImageLabel") or SelectedInstance:IsA("ImageButton") then
        CopyProperties(SelectedInstance, NewObject, IMAGE_PROPERTIES)
    end

    if SelectedInstance:IsA("TextLabel") or SelectedInstance:IsA("TextButton") or SelectedInstance:IsA("TextBox") then
        CopyProperties(SelectedInstance, NewObject, TEXT_PROPERTIES)
    end

    local Attributes = SelectedInstance:GetAttributes()
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

    for _, Child in ipairs(SelectedInstance:GetChildren()) do
        Child.Parent = NewObject
    end

    SelectedInstance:Destroy()
    Selection:Set({NewObject})

    return NewObject
end

return Converter
