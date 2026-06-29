local Interface = {}

-- Services
local SelectionService = game:GetService("Selection")

-- Imports
local Packages = script.Parent.Parent.Packages
local Seam = require(Packages.Seam)
local Jian = require(Packages.Jian)
local Builders = require(script.Modules.Builders)
local Data = require(script.Modules.Data)

-- Variables
local Scope = Seam.Scope(Seam)
local Widget = nil
local CurrentSelectedInstance = Scope:Value(nil)
local ApplyCallbacks = {}
local AutoImportCallbacks = {}
local CreateInstanceCallbacks = {}
local ConvertInstanceCallbacks = {}
local OpenImageMapperCallbacks = {}
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

local function RunCallbacks(callbacks, ...)
    for _, Callback in ipairs(callbacks) do
        Callback(...)
    end
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

    Builders.BuildSection(Scope, Seam, Jian, "Figma Properties", {
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "XPosition", "X Position", IsAnyUIObjectElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "YPosition", "Y Position", IsAnyUIObjectElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "Width", "Width", IsDefaultElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "Height", "Height", IsDefaultElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "Name", "Name", IsDefaultElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "ImageId", "Image Id", IsAnyUIObjectElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "AnchorPointX", "Anchor Point X", IsAnyUIObjectElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "AnchorPointY", "Anchor Point Y", IsAnyUIObjectElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "StrokeThickness", "Stroke Thickness", IsAnyUIObjectElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "ShadowX", "Shadow X Offset", IsAnyUIObjectElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "ShadowY", "Shadow Y Offset", IsAnyUIObjectElementEnabled),
            Builders.BuildTextInput(Scope, InputRefs, Jian, "ShadowSpread", "Shadow Spread", IsAnyUIObjectElementEnabled),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildTextInput(Scope, InputRefs, Jian, "ShadowRadius", "Shadow Radius", IsAnyUIObjectElementEnabled),
        }),
    }, ScrollingList, true)

    Builders.BuildSection(Scope, Seam, Jian, "Settings", {
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Aspect Ratio Constraint", IsAnyUIObjectElementEnabled, SettingValues.KeepAspectRatio, UDim2.fromScale(0.95, 1)),
        }, 22),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Clip Descendants", IsAnyUIObjectElementEnabled, SettingValues.ClipDescendants, UDim2.fromScale(0.95, 1)),
        }, 22),
    }, ScrollingList, true)

    Builders.BuildSection(Scope, Seam, Jian, "Instance Building", {
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "New ImageLabel", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ImageLabel", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New ImageButton", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ImageButton", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New TextLabel", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextLabel", CurrentSelectedInstance.Value)
            end),
        }),
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "New TextButton", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextButton", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New TextBox", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "TextBox", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New Frame", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "Frame", CurrentSelectedInstance.Value)
            end),
        }),
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "New ScrollingFrame", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "ScrollingFrame", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New UICorner", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "UICorner", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "New UIStroke", IsDefaultElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(CreateInstanceCallbacks, "UIStroke", CurrentSelectedInstance.Value)
            end),
        }),
    }, ScrollingList)

    Builders.BuildSection(Scope, Seam, Jian, "Convert Selected", {
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "To ImageLabel", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ImageLabel", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "To ImageButton", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ImageButton", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "To Frame", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "Frame", CurrentSelectedInstance.Value)
            end),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "To TextLabel", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextLabel", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "To TextButton", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextButton", CurrentSelectedInstance.Value)
            end),

            Builders.BuildButton(Scope, Seam, Jian, "To TextBox", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.3, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "TextBox", CurrentSelectedInstance.Value)
            end),
        }),
        
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "To ScrollingFrame", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.95, 1), function()
                RunCallbacks(ConvertInstanceCallbacks, "ScrollingFrame", CurrentSelectedInstance.Value)
            end),
        }),
    }, ScrollingList)

    Builders.BuildSection(Scope, Seam, Jian, "Image Mapping", {
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "Open Image Mapping Widget", IsAnyUIObjectElementEnabled, UDim2.fromScale(0.95, 1), function()
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

    Builders.BuildSection(Scope, Seam, Jian, "Auto Import", {
        Scope:New(Jian.Text, {
            Visible = ShowAutoImportWarning,
            Active = IsAutoImportElementEnabled,
            Text = "Auto import requires selecting a ScreenGui.",
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 24),
        }),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Aspect Ratio Constraints", IsAutoImportElementEnabled, SettingValues.KeepAspectRatio),
            Builders.BuildCheckbox(Scope, Jian, "Default Opportunistic", IsAutoImportElementEnabled, SettingValues.DefaultOpportunisticMode),
        }, 22),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Import Frames", IsAutoImportElementEnabled, SettingValues.ImportFramesAsFrames),
            Builders.BuildCheckbox(Scope, Jian, "Import Text", IsAutoImportElementEnabled, SettingValues.ImportTextAsText),
        }, 22),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Import Strokes", IsAutoImportElementEnabled, SettingValues.ImportStrokesAsUIStroke),
            Builders.BuildCheckbox(Scope, Jian, "Background Color", IsAutoImportElementEnabled, SettingValues.ApplyBackgroundColor),
        }, 22),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Auto Layout", IsAutoImportElementEnabled, SettingValues.ApplyAutoLayout),
            Builders.BuildCheckbox(Scope, Jian, "Corner Radius", IsAutoImportElementEnabled, SettingValues.RespectCornerRadius),
        }, 22),

        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildCheckbox(Scope, Jian, "Frame Opacity", IsAutoImportElementEnabled, SettingValues.RespectFrameOpacity, UDim2.fromScale(0.95, 1)),
        }, 22),

        InputRefs.ImportJSON,
        
        Builders.BuildRow(Scope, Seam, Jian, {
            Builders.BuildButton(Scope, Seam, Jian, "Auto Import (Opportunistic)", IsAutoImportElementEnabled, UDim2.fromScale(0.475, 1), function()
                Data.ApplyImportSettingsToRoot(Seam, CurrentSelectedInstance.Value, SettingValues)
                RunCallbacks(AutoImportCallbacks, "opportunistic", Builders.ReadText(InputRefs, "ImportJSON"), CurrentSelectedInstance.Value)
            end),
            Builders.BuildButton(Scope, Seam, Jian, "Auto Import (Classic)", IsAutoImportElementEnabled, UDim2.fromScale(0.475, 1), function()
                Data.ApplyImportSettingsToRoot(Seam, CurrentSelectedInstance.Value, SettingValues)
                RunCallbacks(AutoImportCallbacks, "classic", Builders.ReadText(InputRefs, "ImportJSON"), CurrentSelectedInstance.Value)
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

            local ApplyData = Data.CollectApplyData(Selected, function(key)
                return Builders.ReadText(InputRefs, key)
            end, SettingValues)
            RunCallbacks(ApplyCallbacks, ApplyData, Selected)
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
                Data.ApplySelectionToInputs(nil, InputRefs, SettingValues)
                return
            end

            local SelectedObject = Selection[1]

            if SelectedObject:IsA("GuiObject") or SelectedObject:IsA("ScreenGui") then
                CurrentSelectedInstance.Value = SelectedObject
                Data.ApplySelectionToInputs(SelectedObject, InputRefs, SettingValues)
                return
            end

            CurrentSelectedInstance.Value = nil
            Data.ApplySelectionToInputs(nil, InputRefs, SettingValues)
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
    Data.ApplySelectionToInputs(SelectedInstance, InputRefs, SettingValues)
end

return Interface

