-- Services
local Selection = game:GetService("Selection")

-- Imports
local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local BuildSectionFrame = require(script.Parent.SectionFrame)
local Fusion = require(Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value


local function GetDictionaryLength(dictionary)
    local Count = 0

    for _ in pairs(dictionary) do
        Count += 1
    end

    return Count
end

return function(mainContentList, isItemSelected, inputs, sectionBuildData)
    local Selected = Value(nil)

    local SectionFrame = Hydrate(BuildSectionFrame(mainContentList)) {
        Visible = Computed(function()
            if isItemSelected:get() and Selected:get() and (not Selected:get():IsA("ScreenGui") or (sectionBuildData.Name or sectionBuildData.SizeX or sectionBuildData.SizeY or sectionBuildData.AutoImportData)) then
                return true
            else
                return false
            end
        end)
    }

    local InputSize = 1 / (GetDictionaryLength(sectionBuildData) * 1.1)

    for Name, Data in pairs(sectionBuildData) do
        local PreviousText = Data.PreviousText or ""

        local Input; Input = Component "TextInput" {
            Enabled = Computed(function()
                return isItemSelected:get() and Selected:get() and (not Selected:get():IsA("ScreenGui") or (Name == "Name" or Name == "SizeX" or Name == "SizeY" or Name == "AutoImportData"))
            end),
            Name = Name,
            PlaceholderText = Data.PlaceholderText or Name,
            LayoutOrder = Data.LayoutOrder or 0,
            Text = PreviousText,
            Size = UDim2.fromScale(InputSize, 1),
            Parent = SectionFrame,

            [Children] = Data.Children,

            [OnEvent "FocusLost"] = function()
                local InputText = Input.Text

                if tonumber(InputText) then
                    InputText = tonumber(InputText)
                end

                if Data.Type then
                    if typeof(InputText) ~= Data.Type then
                        Input.Text = ""
                        return
                    end
                end

                PreviousText = InputText
            end
        }

        inputs[Name] = Input
    end

    Selection.SelectionChanged:Connect(function()
        Selected:set(Selection:Get()[1])
    end)

    return SectionFrame
end