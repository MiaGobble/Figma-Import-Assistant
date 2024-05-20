local Interface = {}

-- Constants
local BUILD_DATA = script.Build
local BUILD_SECTIONS_DATA = require(BUILD_DATA.Sections)
local TEXT_INPUT_BUILD_DATA = require(BUILD_DATA.TextInputBuildData)
local INSTANCE_BUTTON_BUILD_DATA = require(BUILD_DATA.InstanceCreationButtons)
local ALIGNMENT_INPUT_BUILD_DATA = require(BUILD_DATA.AlignmentInputs)

-- Imports
local Packages = script.Parent.Parent.Packages
local Component = require(script.Parent.Component)
local SearchWidget = require(script.SearchWidget)
local Fusion = require(Packages.Fusion)
local InstanceCreationButton = require(script.InstanceCreationButton)
local TextInputSection = require(script.TextInputSection)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

-- Variables
local Plugin = script:FindFirstAncestorOfClass("Plugin")
local Widget = nil
local MainContentList = nil
local SelectedItem = Value(nil)
local IsItemSelected = Value(false)
local Inputs = {}
local ApplyCallback = nil
local BuildTypes = {}

-- Functions
local function CreateInstanceCreationButton(...)
    return InstanceCreationButton(Inputs, MainContentList, SelectedItem, IsItemSelected, ...)
end

local function CreateTextInputSection(...)
    return TextInputSection(MainContentList, IsItemSelected, Inputs, ...)
end

-- Build type callbacks
function BuildTypes.CreationButtons(SectionFrame)
    for _, Data in ipairs(INSTANCE_BUTTON_BUILD_DATA) do
        for PropertyKey, Value in Data.Properties do
            if PropertyKey:find("Color3") then
                Data.Properties[PropertyKey] = Color3.fromRGB(unpack(Value))
            elseif PropertyKey:find("Size") or PropertyKey:find("Position") then
                Data.Properties[PropertyKey] = UDim2.new(unpack(Value))
            end
        end

        Hydrate(CreateInstanceCreationButton(Data)) {
            Parent = SectionFrame
        }
    end

    Hydrate(Inputs["Image"]) {
        Visible = Computed(function()
            local Success, _ = pcall(function()
                return SelectedItem:get().Image
            end)

            return Success
        end)
    }
end

function BuildTypes.TextInputSections(SectionFrame)
    for _, Data in ipairs(TEXT_INPUT_BUILD_DATA) do
        Hydrate(CreateTextInputSection(Data)) {
            Parent = SectionFrame
        }
    end
end

function BuildTypes.AlignmentInputs(SectionFrame)
    for _, Data in ipairs(ALIGNMENT_INPUT_BUILD_DATA) do
        Hydrate(CreateTextInputSection(Data)) {
            Parent = SectionFrame
        }
    end
end

-- Functions (extended)
local function BuildSections()
    for _, SectionData in BUILD_SECTIONS_DATA do
        local Section = Component "VerticalCollapsibleSection" {
            Size = UDim2.new(1, 0, 0, 30),
            Parent = MainContentList,

            Collapsed = if SectionData.Collapsed ~= nil then SectionData.Collapsed else true,
            Text = SectionData.Name,
            Enabled = true,

            [Children] = {
                New "UIPadding" {
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 8),
                },
                
                New "UIListLayout" {
                    Padding = UDim.new(0, 16),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                },
            }
        }

        for _, BuildType in SectionData.Build do
            BuildTypes[BuildType](Section)
        end
    end
end

local function Apply()
    if ApplyCallback then
        local Stroke = tonumber(Inputs["StrokeThickness"].Text) or 0
        local Oblique = tonumber(Inputs["ObliqueShadowSize"].Text) or 0

        ApplyCallback {
            Size = {
                X = Inputs["SizeX"].Text,
                Y = Inputs["SizeY"].Text
            },

            Position = {
                X = Inputs["PositionX"].Text,
                Y = Inputs["PositionY"].Text,
            },

            AnchorPoint = {
                X = tonumber(Inputs["AnchorX"].Text) or 0,
                Y = tonumber(Inputs["AnchorY"].Text) or 0
            },

            Name = Inputs["Name"].Text,
            Image = Inputs["Image"].Text,
            Stroke = Stroke,
            Oblique = Oblique,
        }
    end
end

local function BuildInterface()
    local Background = Component "Background" {
		Parent = Widget
	}

	MainContentList = Component("ScrollFrame")({
		UIPadding = New "UIPadding" {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
		},
		
		UILayout = New "UIListLayout" {
			Padding = UDim.new(0, 16),
			SortOrder = Enum.SortOrder.LayoutOrder,
		},

        CanvasScaleConstraint = Enum.ScrollingDirection.X,
        ZIndex = 1,
		
		Parent = Widget,
	}).Canvas
	
	local MainContentMargins = New "UIPadding" {
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = Widget
	}
	
	local TopListPadding = Component "Background" {
		Size = UDim2.new(1, 0, 0, 0),
		Parent = MainContentList
	}
	
	local TitleLabel = Component "Title" {
		Text = "Figma Import Assistant",
		TextYAlignment = Enum.TextYAlignment.Center,
		Visible = true,
		LayoutOrder = 0,
		Parent = MainContentList,
	}

    BuildSections()

    Inputs["ApplyButton"] = Component "Button" {
        Enabled = IsItemSelected,
        Name = "Apply",
        Text = "Apply",
        LayoutOrder = 5,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainContentList,

        [OnEvent "Activated"] = Apply
    }
end

-- Methods
function Interface:Init()
    Widget = Component "Widget" {
        Id = "FigmaImportAssistant",
        Name = "Figma Import Assistant",
        InitialDockTo = "Float",
        InitialEnabled = false,
        ForceInitialEnabled = false,
        FloatingSize = Vector2.new(300, 400),
        MinimumSize = Vector2.new(300, 400),
    }

    BuildInterface()

    SearchWidget:Build()
end

function Interface:ToggleVisibility()
    if Widget then
        Widget.Enabled = not Widget.Enabled
    end
end

function Interface:OnApply(...)
    ApplyCallback = ...
end

function Interface:OnSelection(Item)
    SelectedItem:set(Item)
    IsItemSelected:set(Item ~= nil)

    if Item == nil then
        return
    end

    if Item:GetAttribute("FigmaSize") then
        Inputs["SizeX"].Text = Item:GetAttribute("FigmaSize").X
        Inputs["SizeY"].Text = Item:GetAttribute("FigmaSize").Y
    else
        Inputs["SizeX"].Text = ""
        Inputs["SizeY"].Text = ""
    end

    if Item:GetAttribute("FigmaPosition") then
        Inputs["PositionX"].Text = Item:GetAttribute("FigmaPosition").X
        Inputs["PositionY"].Text = Item:GetAttribute("FigmaPosition").Y
    else
        Inputs["PositionX"].Text = ""
        Inputs["PositionY"].Text = ""
    end

    Inputs["StrokeThickness"].Text = Item:GetAttribute("FigmaStrokeThickness") or 0
    Inputs["ObliqueShadowSize"].Text = Item:GetAttribute("FigmaObliqueSize") or 0

    Inputs["Name"].Text = Item.Name
    
    local DidApplyAnchorPoint = pcall(function()
        Inputs["AnchorX"].Text = Item.AnchorPoint.X
        Inputs["AnchorY"].Text = Item.AnchorPoint.Y
    end)

    if not DidApplyAnchorPoint then
        Inputs["AnchorX"].Text = ""
        Inputs["AnchorY"].Text = ""
    end

    local DidApplyImage = pcall(function()
        Inputs["Image"].Text = Item.Image
    end)

    if not DidApplyImage then
        Inputs["Image"].Text = ""
    end
end

return Interface