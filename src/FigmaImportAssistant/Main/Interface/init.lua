local Interface = {}

local SelectionService = game:GetService("Selection")

local Packages = script.Parent.Parent.Packages
local Seam = require(Packages.Seam)
local Jian = require(Packages.Jian)

local Scope = Seam.Scope(Seam)
local Widget = nil
local CurrentSelectedInstance = Scope:Value(nil)

local InputRefs = {}
local SettingValues = {
    KeepAspectRatio = Scope:Value(true),
    ClipDescendants = Scope:Value(true),
    ImportFramesAsFrames = Scope:Value(true),
    ImportTextAsText = Scope:Value(true),
    ImportStrokesAsUIStroke = Scope:Value(true),
    ApplyBackgroundColor = Scope:Value(true),
    ApplyAutoLayout = Scope:Value(true),
    RespectCornerRadius = Scope:Value(true),
    RespectFrameOpacity = Scope:Value(true),
    DefaultOpportunisticMode = Scope:Value(true),
}

local ApplyCallbacks = {}
local AutoImportCallbacks = {}
local CreateInstanceCallbacks = {}
local ConvertInstanceCallbacks = {}
local OpenImageMapperCallbacks = {}

local IsDefaultElementEnabled = Scope:Computed(function(Use)
    return Use(CurrentSelectedInstance) ~= nil
end)

local IsAnyUIObjectElementEnabled = Scope:Computed(function(Use)
    local Selected = Use(CurrentSelectedInstance)
    return Selected ~= nil and (Selected:IsA("GuiObject") or Selected:IsA("ScreenGui"))
end)

local IsAutoImportElementEnabled = Scope:Computed(function(Use)
    local Selected = Use(CurrentSelectedInstance)
    return Selected ~= nil and Selected:IsA("ScreenGui")
end)

local ShowNoSelectionWarning = Scope:Computed(function(Use)
    return Use(CurrentSelectedInstance) == nil
end)

local ShowAutoImportWarning = Scope:Computed(function(Use)
    local Selected = Use(CurrentSelectedInstance)
    return Selected == nil or not Selected:IsA("ScreenGui")
end)

local function ToNumber(Value, Fallback)
    local Number = tonumber(Value)

    if Number == nil then
        return Fallback
    end

    return Number
end

local function RegisterInput(Key, Input)
    InputRefs[Key] = Input
    return Input
end

local function BuildRow(Children, Height, Padding)
    local ChildList = {
        Scope:New(Jian.ListLayout, {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, Padding or 8),
        }),
    }

    for _, Child in ipairs(Children) do
        table.insert(ChildList, Child)
    end

    return Scope:New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Height or 30),
        [Seam.Children] = ChildList,
    })
end

local function BuildTextInput(Key, Title, ActiveState, Width)
    return RegisterInput(Key, Scope:New(Jian.TextBox, {
        Title = Title,
        Size = Width or UDim2.fromScale(0.45, 1),
        Active = ActiveState,
    }))
end

local function BuildCheckbox(Title, ActiveState, ValueState, Width)
    return Scope:New(Jian.Checkbox, {
        Title = Title,
        Size = Width or UDim2.fromScale(0.45, 1),
        Active = ActiveState,
        Value = ValueState,
    })
end

local function BuildButton(Text, ActiveState, Width, Callback)
    return Scope:New(Jian.TextButton, {
        Text = Text,
        Size = Width or UDim2.fromScale(0.3, 1),
        Active = ActiveState,
        [Seam.OnEvent "Activated"] = Callback,
    })
end

local function ReadText(Key)
    local Ref = InputRefs[Key]

    if not Ref then
        return ""
    end

    return Ref.Text or ""
end

local function FindRootScreenGui(Selected)
    if not Selected then
        return nil
    end

    if Selected:IsA("ScreenGui") then
        return Selected
    end

    return Selected:FindFirstAncestorWhichIsA("ScreenGui")
end

local function ApplySelectionToInputs(Selected)
    local Position = Selected and (Selected:GetAttribute("FigmaPosition") or Vector2.new(0, 0)) or Vector2.new(0, 0)
    local Size = Selected and (Selected:GetAttribute("FigmaSize") or Vector2.new(100, 100)) or Vector2.new(100, 100)

    if Selected and Selected:IsA("GuiObject") then
        if not Selected:GetAttribute("FigmaPosition") then
            Position = Vector2.new(Selected.Position.X.Offset, Selected.Position.Y.Offset)
        end

        if not Selected:GetAttribute("FigmaSize") then
            Size = Vector2.new(Selected.Size.X.Offset, Selected.Size.Y.Offset)
        end
    end

    local ShadowOffset = Selected and (Selected:GetAttribute("FigmaShadowOffset") or Vector2.new(0, 0)) or Vector2.new(0, 0)

    if InputRefs.XPosition then
        InputRefs.XPosition.Text = tostring(Position.X)
    end

    if InputRefs.YPosition then
        InputRefs.YPosition.Text = tostring(Position.Y)
    end

    if InputRefs.Width then
        InputRefs.Width.Text = tostring(Size.X)
    end

    if InputRefs.Height then
        InputRefs.Height.Text = tostring(Size.Y)
    end

    if InputRefs.Name then
        InputRefs.Name.Text = if Selected then Selected.Name else ""
    end

    if InputRefs.ImageId then
        if Selected and (Selected:IsA("ImageLabel") or Selected:IsA("ImageButton")) then
            InputRefs.ImageId.Text = Selected.Image:gsub("rbxassetid://", "")
        else
            InputRefs.ImageId.Text = ""
        end
    end

    if InputRefs.AnchorPointX then
        InputRefs.AnchorPointX.Text = if Selected and Selected:IsA("GuiObject") then tostring(Selected.AnchorPoint.X) else "0"
    end

    if InputRefs.AnchorPointY then
        InputRefs.AnchorPointY.Text = if Selected and Selected:IsA("GuiObject") then tostring(Selected.AnchorPoint.Y) else "0"
    end

    if InputRefs.StrokeThickness then
        InputRefs.StrokeThickness.Text = tostring(if Selected then Selected:GetAttribute("FigmaStrokeThickness") or 0 else 0)
    end

    if InputRefs.ShadowX then
        InputRefs.ShadowX.Text = tostring(ShadowOffset.X)
    end

    if InputRefs.ShadowY then
        InputRefs.ShadowY.Text = tostring(ShadowOffset.Y)
    end

    if InputRefs.ShadowSpread then
        InputRefs.ShadowSpread.Text = tostring(if Selected then Selected:GetAttribute("FigmaShadowSpread") or 0 else 0)
    end

    if InputRefs.ShadowRadius then
        InputRefs.ShadowRadius.Text = tostring(if Selected then Selected:GetAttribute("FigmaShadowRadius") or 0 else 0)
    end

    if not Selected then
        return
    end

    SettingValues.KeepAspectRatio.Value = Selected:GetAttribute("FigmaSetting_IsAspectRatioConstrained")
    if SettingValues.KeepAspectRatio.Value == nil then
        SettingValues.KeepAspectRatio.Value = true
    end

    SettingValues.ClipDescendants.Value = Selected:GetAttribute("FigmaSetting_ClipDescendants")
    if SettingValues.ClipDescendants.Value == nil then
        SettingValues.ClipDescendants.Value = true
    end

    local RootGui = FindRootScreenGui(Selected)

    if RootGui then
        local Mapping = {
            ImportFramesAsFrames = {"FigmaSetting_ImportFramesAsFrames", true},
            ImportTextAsText = {"FigmaSetting_ImportTextAsText", true},
            ImportStrokesAsUIStroke = {"FigmaSetting_ImportStrokesAsUIStroke", true},
            ApplyBackgroundColor = {"FigmaSetting_ApplyBackgroundColor", true},
            ApplyAutoLayout = {"FigmaSetting_ApplyAutoLayout", true},
            RespectCornerRadius = {"FigmaSetting_RespectAutoImportCornerRadius", true},
            RespectFrameOpacity = {"FigmaSetting_RespectAutoImportFrameOpacity", true},
        }

        for SettingName, Data in pairs(Mapping) do
            local AttributeName = Data[1]
            local DefaultValue = Data[2]
            local Value = RootGui:GetAttribute(AttributeName)

            if Value == nil then
                Value = DefaultValue
            end

            SettingValues[SettingName].Value = Value
        end
    end
end

local function CollectApplyData(Selected)
    local PositionAttribute = Selected and Selected:GetAttribute("FigmaPosition") or Vector2.new(0, 0)
    local SizeAttribute = Selected and Selected:GetAttribute("FigmaSize") or Vector2.new(100, 100)
    local ShadowOffset = Selected and Selected:GetAttribute("FigmaShadowOffset") or Vector2.new(0, 0)

    return {
        Size = {
            X = ToNumber(ReadText("Width"), SizeAttribute.X),
            Y = ToNumber(ReadText("Height"), SizeAttribute.Y),
        },
        Position = {
            X = ToNumber(ReadText("XPosition"), PositionAttribute.X),
            Y = ToNumber(ReadText("YPosition"), PositionAttribute.Y),
        },
        AnchorPoint = {
            X = ToNumber(ReadText("AnchorPointX"), if Selected and Selected:IsA("GuiObject") then Selected.AnchorPoint.X else 0),
            Y = ToNumber(ReadText("AnchorPointY"), if Selected and Selected:IsA("GuiObject") then Selected.AnchorPoint.Y else 0),
        },
        Name = if ReadText("Name") ~= "" then ReadText("Name") else if Selected then Selected.Name else "",
        Image = ReadText("ImageId"),
        Stroke = ToNumber(ReadText("StrokeThickness"), if Selected then Selected:GetAttribute("FigmaStrokeThickness") or 0 else 0),
        Oblique = 0,
        Settings = {
            IsAspectRatioConstrained = SettingValues.KeepAspectRatio.Value,
            ClipDescendants = SettingValues.ClipDescendants.Value,
            ImportFramesAsFrames = SettingValues.ImportFramesAsFrames.Value,
            ImportTextAsText = SettingValues.ImportTextAsText.Value,
            ImportStrokesAsUIStroke = SettingValues.ImportStrokesAsUIStroke.Value,
            ApplyBackgroundColor = SettingValues.ApplyBackgroundColor.Value,
            ApplyAutoLayout = SettingValues.ApplyAutoLayout.Value,
            RespectAutoImportCornerRadius = SettingValues.RespectCornerRadius.Value,
            RespectAutoImportFrameOpacity = SettingValues.RespectFrameOpacity.Value,
        },
        Shadow = {
            Offset = Vector2.new(
                ToNumber(ReadText("ShadowX"), ShadowOffset.X),
                ToNumber(ReadText("ShadowY"), ShadowOffset.Y)
            ),
            Spread = ToNumber(ReadText("ShadowSpread"), if Selected then Selected:GetAttribute("FigmaShadowSpread") or 0 else 0),
            Radius = ToNumber(ReadText("ShadowRadius"), if Selected then Selected:GetAttribute("FigmaShadowRadius") or 0 else 0),
        },
    }
end

local function RunCallbacks(Callbacks, ...)
    for _, Callback in ipairs(Callbacks) do
        Callback(...)
    end
end

local function ApplyImportSettingsToRoot(RootGui)
    if not RootGui then
        return
    end

    RootGui:SetAttribute("FigmaSetting_IsAspectRatioConstrained", SettingValues.KeepAspectRatio.Value)
    RootGui:SetAttribute("FigmaSetting_ImportFramesAsFrames", SettingValues.ImportFramesAsFrames.Value)
    RootGui:SetAttribute("FigmaSetting_ImportTextAsText", SettingValues.ImportTextAsText.Value)
    RootGui:SetAttribute("FigmaSetting_ImportStrokesAsUIStroke", SettingValues.ImportStrokesAsUIStroke.Value)
    RootGui:SetAttribute("FigmaSetting_ApplyBackgroundColor", SettingValues.ApplyBackgroundColor.Value)
    RootGui:SetAttribute("FigmaSetting_ApplyAutoLayout", SettingValues.ApplyAutoLayout.Value)
    RootGui:SetAttribute("FigmaSetting_RespectAutoImportCornerRadius", SettingValues.RespectCornerRadius.Value)
    RootGui:SetAttribute("FigmaSetting_RespectAutoImportFrameOpacity", SettingValues.RespectFrameOpacity.Value)
end

local function BuildSection(Text, Children, Parent, OpenByDefault)
    return Scope:New(Jian.ListSection, {
        Text = Text,
        Parent = Parent,
        OpenByDefault = OpenByDefault,
        [Seam.Children] = Children,
    })
end

local function BuildInterface()
    local ScrollingList = Scope:New(Jian.ScrollingList, {
        Parent = Widget,
    })

    Scope:New(Jian.Background, {
        Parent = Widget,
    })

    Scope:New(Jian.Padding, {
        Parent = ScrollingList,
    })

    Scope:New(Jian.Text, {
        Parent = ScrollingList,
        Visible = ShowNoSelectionWarning,
        Active = IsDefaultElementEnabled,
        Text = "Select a UI object (ScreenGui or GuiObject) to start using the plugin.",
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 36),
    })

    BuildSection("Figma Properties", {
        BuildRow({
            BuildTextInput("XPosition", "X Position", IsAnyUIObjectElementEnabled),
            BuildTextInput("YPosition", "Y Position", IsAnyUIObjectElementEnabled),
        }),
        BuildRow({
            BuildTextInput("Width", "Width", IsDefaultElementEnabled),
            BuildTextInput("Height", "Height", IsDefaultElementEnabled),
        }),
        BuildRow({
            BuildTextInput("Name", "Name", IsDefaultElementEnabled),
            BuildTextInput("ImageId", "Image Id", IsAnyUIObjectElementEnabled),
        }),
        BuildRow({
            BuildTextInput("AnchorPointX", "Anchor Point X", IsAnyUIObjectElementEnabled),
            BuildTextInput("AnchorPointY", "Anchor Point Y", IsAnyUIObjectElementEnabled),
        }),
        BuildRow({
            BuildTextInput("StrokeThickness", "Stroke Thickness", IsAnyUIObjectElementEnabled),
            BuildTextInput("ShadowX", "Shadow X Offset", IsAnyUIObjectElementEnabled),
        }),
        BuildRow({
            BuildTextInput("ShadowY", "Shadow Y Offset", IsAnyUIObjectElementEnabled),
            BuildTextInput("ShadowSpread", "Shadow Spread", IsAnyUIObjectElementEnabled),
        }),
        BuildRow({
            BuildTextInput("ShadowRadius", "Shadow Radius", IsAnyUIObjectElementEnabled),
        }),
    }, ScrollingList, true)

    BuildSection("Settings", {
        BuildRow({
            BuildCheckbox("Aspect Ratio Constraint", IsAnyUIObjectElementEnabled, SettingValues.KeepAspectRatio, UDim2.fromScale(0.95, 1)),
        }, 22),
        BuildRow({
            BuildCheckbox("Clip Descendants", IsAnyUIObjectElementEnabled, SettingValues.ClipDescendants, UDim2.fromScale(0.95, 1)),
        }, 22),
    }, ScrollingList, true)

    BuildSection("Instance Building", {
        BuildRow({
            BuildButton("New ImageLabel", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ImageLabel", CurrentSelectedInstance.Value)
            end),
            BuildButton("New ImageButton", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ImageButton", CurrentSelectedInstance.Value)
            end),
            BuildButton("New TextLabel", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextLabel", CurrentSelectedInstance.Value)
            end),
        }),
        BuildRow({
            BuildButton("New TextButton", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextButton", CurrentSelectedInstance.Value)
            end),
            BuildButton("New TextBox", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextBox", CurrentSelectedInstance.Value)
            end),
            BuildButton("New Frame", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "Frame", CurrentSelectedInstance.Value)
            end),
        }),
        BuildRow({
            BuildButton("New ScrollingFrame", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ScrollingFrame", CurrentSelectedInstance.Value)
            end),
            BuildButton("New UICorner", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "UICorner", CurrentSelectedInstance.Value)
            end),
            BuildButton("New UIStroke", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "UIStroke", CurrentSelectedInstance.Value)
            end),
        }),
    }, ScrollingList)

    BuildSection("Convert Selected", {
        BuildRow({
            BuildButton("To ImageLabel", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ImageLabel", CurrentSelectedInstance.Value)
            end),
            BuildButton("To ImageButton", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ImageButton", CurrentSelectedInstance.Value)
            end),
            BuildButton("To Frame", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "Frame", CurrentSelectedInstance.Value)
            end),
        }),
        BuildRow({
            BuildButton("To TextLabel", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextLabel", CurrentSelectedInstance.Value)
            end),
            BuildButton("To TextButton", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextButton", CurrentSelectedInstance.Value)
            end),
            BuildButton("To TextBox", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextBox", CurrentSelectedInstance.Value)
            end),
        }),
        BuildRow({
            BuildButton("To ScrollingFrame", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.95, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ScrollingFrame", CurrentSelectedInstance.Value)
            end),
        }),
    }, ScrollingList)

    BuildSection("Image Mapping", {
        BuildRow({
            BuildButton("Open Image Mapping Widget", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.95, 1), function()
                RunCallbacks(OpenImageMapperCallbacks)
            end),
        }),
    }, ScrollingList)

    InputRefs.ImportJSON = Scope:New("TextBox", {
        MultiLine = true,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        PlaceholderText = "Paste export JSON here...",
        Size = UDim2.new(1, 0, 0, 100),
        Text = "",
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Font = Enum.Font.BuilderSans,
        TextSize = 14,
        Active = IsAutoImportElementEnabled,
        Interactable = IsAutoImportElementEnabled,
        [Seam.Children] = {
            Scope:New("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
            Scope:New("UIStroke", {
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(40, 40, 40),
            }),
        },
    })

    BuildSection("Auto Import", {
        Scope:New(Jian.Text, {
            Visible = ShowAutoImportWarning,
            Active = IsAutoImportElementEnabled,
            Text = "Auto import requires selecting a ScreenGui.",
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 24),
        }),
        BuildRow({
            BuildCheckbox("Aspect Ratio Constraints", IsAutoImportElementEnabled, SettingValues.KeepAspectRatio),
            BuildCheckbox("Default Opportunistic", IsAutoImportElementEnabled, SettingValues.DefaultOpportunisticMode),
        }, 22),
        BuildRow({
            BuildCheckbox("Import Frames", IsAutoImportElementEnabled, SettingValues.ImportFramesAsFrames),
            BuildCheckbox("Import Text", IsAutoImportElementEnabled, SettingValues.ImportTextAsText),
        }, 22),
        BuildRow({
            BuildCheckbox("Import Strokes", IsAutoImportElementEnabled, SettingValues.ImportStrokesAsUIStroke),
            BuildCheckbox("Background Color", IsAutoImportElementEnabled, SettingValues.ApplyBackgroundColor),
        }, 22),
        BuildRow({
            BuildCheckbox("Auto Layout", IsAutoImportElementEnabled, SettingValues.ApplyAutoLayout),
            BuildCheckbox("Corner Radius", IsAutoImportElementEnabled, SettingValues.RespectCornerRadius),
        }, 22),
        BuildRow({
            BuildCheckbox("Frame Opacity", IsAutoImportElementEnabled, SettingValues.RespectFrameOpacity, UDim2.fromScale(0.95, 1)),
        }, 22),
        InputRefs.ImportJSON,
        BuildRow({
            BuildButton("Auto Import (Opportunistic)", IsAutoImportElementEnabled, UDim2.fromScale(0.475, 1), function()
                ApplyImportSettingsToRoot(CurrentSelectedInstance.Value)
                RunCallbacks(AutoImportCallbacks, "opportunistic", ReadText("ImportJSON"), CurrentSelectedInstance.Value)
            end),
            BuildButton("Auto Import (Classic)", IsAutoImportElementEnabled, UDim2.fromScale(0.475, 1), function()
                ApplyImportSettingsToRoot(CurrentSelectedInstance.Value)
                RunCallbacks(AutoImportCallbacks, "classic", ReadText("ImportJSON"), CurrentSelectedInstance.Value)
            end),
        }),
    }, ScrollingList, true)

    Scope:New(Jian.TextButton, {
        Parent = ScrollingList,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "Apply Changes",
        Active = IsDefaultElementEnabled,
        [Seam.OnEvent "Activated"] = function()
            local Selected = CurrentSelectedInstance.Value

            if not Selected then
                return
            end

            local Data = CollectApplyData(Selected)
            RunCallbacks(ApplyCallbacks, Data, Selected)
        end,
    })
end

function Interface.Init()
    Widget = Scope:New(Jian.Widget, {
        WidgetId = "FigmaImportAssistant",
        Title = "Figma Import Assistant",
        InitialDockState = Enum.InitialDockState.Float,
        InitialEnabled = true,
        OverridePreviousState = false,
        DefaultWidth = 360,
        DefaultHeight = 560,
        MinimumWidth = 320,
        MinimumHeight = 400,
    })

    BuildInterface()

    Scope:New(SelectionService, {
        [Seam.OnEvent "SelectionChanged"] = function()
            local Selection = SelectionService:Get()

            if #Selection ~= 1 then
                CurrentSelectedInstance.Value = nil
                ApplySelectionToInputs(nil)
                return
            end

            local SelectedObject = Selection[1]

            if SelectedObject:IsA("GuiObject") or SelectedObject:IsA("ScreenGui") then
                CurrentSelectedInstance.Value = SelectedObject
                ApplySelectionToInputs(SelectedObject)
                return
            end

            CurrentSelectedInstance.Value = nil
            ApplySelectionToInputs(nil)
        end,
    })
end

function Interface.ToggleVisibility()
    if Widget then
        Widget.Enabled = not Widget.Enabled
    end
end

function Interface.OnApply(Callback)
    table.insert(ApplyCallbacks, Callback)
end

function Interface.OnAutoImport(Callback)
    table.insert(AutoImportCallbacks, Callback)
end

function Interface.OnCreateInstance(Callback)
    table.insert(CreateInstanceCallbacks, Callback)
end

function Interface.OnConvertInstance(Callback)
    table.insert(ConvertInstanceCallbacks, Callback)
end

function Interface.OnOpenImageMapper(Callback)
    table.insert(OpenImageMapperCallbacks, Callback)
end

function Interface.OnSelection(SelectedInstance)
    CurrentSelectedInstance.Value = SelectedInstance
    ApplySelectionToInputs(SelectedInstance)
end

return Interface
