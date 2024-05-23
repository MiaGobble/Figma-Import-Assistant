local AppImportInterpreter = {}

local TAG_ACTIONS = {
    ["GROUP"] = "BreakAfter",
    ["IGNORE"] = "Continue"
}

local HttpService = game:GetService("HttpService")

local function ReadRecursive(ParentTable)
    local ChildTable = {
        Root = {},
    }

    for _, Child in ipairs(ParentTable) do
        local Interpretation = {
            Size = {
                X = Child.width,
                Y = Child.height
            },
    
            Position = {
                X = Child.x,
                Y = Child.y,
            },
    
            AnchorPoint = {
                X = 0,
                Y = 0
            },
    
            Name = Child.name or "AUTOIMPORT",
            Image = "",
            Stroke = Child.strokeWeight or 0,
            Oblique = 0,
    
            -- Unique data from import
            Type = if Child.opacity == 0 and Child.strokeWeight == 0 then "Frame" else "ImageLabel"
        }

        if Child.children then
            Interpretation.Children = ReadRecursive(Child.children)
        else
            Interpretation.Children = {}
        end
    
        table.insert(ChildTable.Root, Interpretation)
    end

    -- if ParentTable.children then
    --     ChildTable.Children = ReadRecursive(ParentTable.children)
    -- end

    return ChildTable
end

function AppImportInterpreter:InterpretJSONData(JSONData : string)
    local Data = HttpService:JSONDecode(JSONData)
    local Interpretation = ReadRecursive(Data)

    return Interpretation
end

function AppImportInterpreter:GetActionsFromName(Name : string)
    local RawTags = string.split(Name:upper(), "@")
    local Name = RawTags[1]
    local Actions = {}

    for Index, Tag in ipairs(RawTags) do
        if Index > 1 and TAG_ACTIONS[Tag] then
            Actions[TAG_ACTIONS[Tag]] = true
        end
    end

    return Actions, Name
end

return AppImportInterpreter