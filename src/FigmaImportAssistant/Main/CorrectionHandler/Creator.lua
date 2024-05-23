local Creator = {}

local Applicator = require(script.Parent.Applicator)

local function CreateRecursive(Parent, Data : {})
    for _, Child in Data.Root do
        local Object = Instance.new(Child.Type)
        Object.ClipsDescendants = Child.clipsContent or true
        Object.BackgroundTransparency = 1
        Object.Parent = Parent

        Applicator:ApplyChangesFromData(Object, Child)

        if Child.Children then
            CreateRecursive(Object, Child.Children)
        end
    end
end

function Creator:CreateFromData(SelectedInstance, Data : {})
    CreateRecursive(SelectedInstance, Data)
end

return Creator