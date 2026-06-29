local ImageMapper = {}

local SelectionService = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local Seam = require(Packages.Seam)
local Jian = require(Packages.Jian)
local Utility = require(script.Parent.Utility)

local Scope = Seam.Scope(Seam)
local Widget = nil
local List = nil
local ImageInputs = {}

local function GetCurrentScreenGui()
    local Selection = SelectionService:Get()

    if #Selection ~= 1 then
        return nil
    end

    local Selected = Selection[1]

    if Selected:IsA("ScreenGui") then
        return Selected
    end

    return Selected:FindFirstAncestorWhichIsA("ScreenGui")
end

local function CollectHierarchyRecursive(Parent : Instance, Depth : number, PathPrefix : string, Output : {})
    local BranchEntries = {}
    local BranchHasImage = false

    for _, Child in ipairs(Parent:GetChildren()) do
        local IsImage = Child:IsA("ImageLabel") or Child:IsA("ImageButton")
        local Entry = {
            Object = Child,
            Depth = Depth,
            Path = PathPrefix .. "/" .. Child.Name,
            IsImage = IsImage,
        }

        local ChildBranchEntries = {}
        local ChildHasImage = CollectHierarchyRecursive(Child, Depth + 1, PathPrefix .. "/" .. Child.Name, ChildBranchEntries)

        if IsImage or ChildHasImage then
            table.insert(BranchEntries, Entry)

            for _, ChildEntry in ipairs(ChildBranchEntries) do
                table.insert(BranchEntries, ChildEntry)
            end

            BranchHasImage = true
        end
    end

    if BranchHasImage then
        for _, Entry in ipairs(BranchEntries) do
            table.insert(Output, Entry)
        end
    end

    return BranchHasImage
end

local function ClearListRows()
    ImageInputs = {}

    if not List then
        return
    end

    for _, Child in ipairs(List:GetChildren()) do
        if string.sub(Child.Name, 1, 13) == "ImageMapItem_" then
            Child:Destroy()
        end
    end
end

local function AddInfoRow(Text : string)
    Scope:New("TextLabel", {
        Name = "ImageMapItem_Info",
        Parent = List,
        BackgroundTransparency = 1,
        Text = Text,
        TextColor3 = Color3.fromRGB(163, 163, 163),
        Font = Enum.Font.BuilderSans,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 34),
    })
end

local function BuildImageRow(Index : number, Entry : {})
    local ExistingImage = if Entry.IsImage then Entry.Object.Image or "" else ""
    local HasImage = ExistingImage ~= ""
    local DisplayName = Entry.Object.Name .. " [" .. Entry.Object.ClassName .. "]"

    local Row = Scope:New("Frame", {
        Name = "ImageMapItem_" .. tostring(Index),
        Parent = List,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
    })

    Scope:New(Jian.ListLayout, {
        Parent = Row,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    })

    local NameLabel = Scope:New("TextLabel", {
        Parent = Row,
        BackgroundTransparency = 1,
        Size = if Entry.IsImage then UDim2.fromScale(0.56, 1) else UDim2.fromScale(1, 1),
        Text = DisplayName,
        TextColor3 = if Entry.IsImage and not HasImage then Color3.fromRGB(255, 170, 40) else Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.BuilderSans,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    Scope:New("UIPadding", {
        Parent = NameLabel,
        PaddingLeft = UDim.new(0, Entry.Depth * 14),
    })

    if not Entry.IsImage then
        return
    end

    local Input = Scope:New("TextBox", {
        Parent = Row,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Font = Enum.Font.BuilderSans,
        TextSize = 13,
        ClearTextOnFocus = false,
        PlaceholderText = "rbxassetid://...",
        Text = ExistingImage:gsub("rbxassetid://", ""),
        Size = UDim2.fromScale(0.4, 1),
        Active = true,
        Interactable = true,
    })

    Scope:New("UICorner", {
        Parent = Input,
        CornerRadius = UDim.new(0, 6),
    })

    Scope:New("UIStroke", {
        Parent = Input,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(40, 40, 40),
    })

    table.insert(ImageInputs, {
        Object = Entry.Object,
        Input = Input,
    })
end

local function BuildApplyButtonRow()
    local Row = Scope:New("Frame", {
        Name = "ImageMapItem_ApplyRow",
        Parent = List,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
    })

    Scope:New(Jian.TextButton, {
        Parent = Row,
        Text = "Apply All Images",
        Active = true,
        Size = UDim2.fromScale(1, 1),
        [Seam.OnEvent "Activated"] = function()
            for _, Data in ipairs(ImageInputs) do
                Utility.ApplyImage(Data.Object, Data.Input.Text)
            end

            -- Rebuild to refresh warning colors after apply.
            ImageMapper.Refresh()
        end,
    })
end

function ImageMapper.Refresh()
    if not Widget or not Widget.Enabled then
        return
    end

    ClearListRows()

    local RootGui = GetCurrentScreenGui()

    if not RootGui then
        AddInfoRow("Select a ScreenGui or one of its descendants to map images.")
        return
    end

    local HierarchyEntries = {}
    CollectHierarchyRecursive(RootGui, 0, RootGui.Name, HierarchyEntries)

    if #HierarchyEntries == 0 then
        AddInfoRow("No instances found in this ScreenGui hierarchy.")
        return
    end

    for Index, Entry in ipairs(HierarchyEntries) do
        BuildImageRow(Index, Entry)
    end

    BuildApplyButtonRow()
end

function ImageMapper.Init()
    Widget = Scope:New(Jian.Widget, {
        WidgetId = "FigmaImportAssistantImageMapper",
        Title = "Figma Image Mapper",
        InitialDockState = Enum.InitialDockState.Float,
        InitialEnabled = false,
        OverridePreviousState = false,
        DefaultWidth = 460,
        DefaultHeight = 500,
        MinimumWidth = 360,
        MinimumHeight = 280,
    })

    Scope:New(Jian.Background, {
        Parent = Widget,
    })

    List = Scope:New(Jian.ScrollingList, {
        Parent = Widget,
    })

    Scope:New(Jian.Padding, {
        Parent = List,
    })

    SelectionService.SelectionChanged:Connect(function()
        ImageMapper.Refresh()
    end)
end

function ImageMapper.Toggle()
    if not Widget then
        return
    end

    Widget.Enabled = not Widget.Enabled
    ImageMapper.Refresh()
end

return ImageMapper
