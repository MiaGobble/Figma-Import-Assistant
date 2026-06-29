local SearchWidget = {}

-- Imports
local Packages = script.Parent.Parent.Parent.Packages
local Keybinds = require(script.Parent.Keybinds)
local Component = require(script.Parent.Parent.Component)
local Fusion = require(Packages.Fusion)
local New = Fusion.New

-- Variables
local Widget = nil


local function RunSearch(searchTerm)
    local KeybindResults = Keybinds:GetKeybindsFromSearch(searchTerm)

    if #KeybindResults ~= 1 then
        print(`No keybinds found for search term: {searchTerm}`)
        return
    end

    KeybindResults[1]:Run()
end

function SearchWidget:Build()
    Widget = Component "Widget" {
        Id = "FigmaImportAssistantSearch",
        Name = "Figma Import Assistant Search",
        InitialDockTo = "Float",
        InitialEnabled = true,
        ForceInitialEnabled = true,
        FloatingSize = Vector2.new(300, 30),
        MinimumSize = Vector2.new(300, 30),
    }

        local MainContent = Component "Background" {
		Parent = Widget
	}
	
    New "UIPadding" {
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = Widget
	}
	
    local SearchBox = Component "TextInput" {
        Size = UDim2.fromScale(1, 1),
        PlaceholderText = "Run Command...",
        Parent = MainContent,
    } :: TextBox

    task.delay(0.5, function() -- Fixes weird behavior
        Widget.Enabled = false
    end)

    SearchBox.FocusLost:Connect(function()
        Widget.Enabled = false
        SearchBox.Selectable = false
        SearchBox.Active = false

        RunSearch(SearchBox.Text)

        SearchBox.Text = ""
    end)

    Keybinds:AddKeybind("FigmaImportAssistantSearch", {Enum.KeyCode.LeftAlt, Enum.KeyCode.O}):SetCallback(function()
        Widget.Enabled = true
        SearchBox.Selectable = true
        SearchBox.Active = true

        task.delay(0.2, function()
            SearchBox:CaptureFocus()
        end)

        return true
    end)
end

return SearchWidget