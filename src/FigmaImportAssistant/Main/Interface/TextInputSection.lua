local Selection = game:GetService("Selection")

local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local BuildSectionFrame = require(script.Parent.SectionFrame)
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value

local function GetDictionaryLength(Dictionary)
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

return function(MainContentList, IsItemSelected, Inputs, SectionBuildData)
    local Selected = Value(nil)

    local SectionFrame = Hydrate(BuildSectionFrame(MainContentList)) {
        Visible = Computed(function()
            if Selected:get() and (not Selected:get():IsA("ScreenGui") or SectionBuildData.Name) then
                return true
            else
                return false
            end
        end)
    }

    local InputSize = 1 / (GetDictionaryLength(SectionBuildData) * 1.1)

    for Name, Data in SectionBuildData do
        local PreviousText = Data.PreviousText or ""

        local Input; Input = Component "TextInput" {
            Enabled = Computed(function()
                return Selected:get() and (not Selected:get():IsA("ScreenGui") or Name == "Name")
            end),
            Name = Name,
            PlaceholderText = Data.PlaceholderText or Name,
            LayoutOrder = Data.LayoutOrder or 0,
            Text = PreviousText,
            Size = UDim2.new(InputSize, 0, 1, 0),
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

        Inputs[Name] = Input
    end

    Selection.SelectionChanged:Connect(function()
        Selected:set(Selection:Get()[1])
    end)

    return SectionFrame
end