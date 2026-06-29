local Builders = {}

function Builders.RegisterInput(inputRefs, key, input)
    inputRefs[key] = input
    return input
end

function Builders.ReadText(inputRefs, key)
    local Ref = inputRefs[key]

    if not Ref then
        return ""
    end

    return Ref.Text or ""
end

function Builders.BuildRow(scope, seam, jian, children, height, padding)
    local ChildList = {
        scope:New(jian.ListLayout, {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, padding or 8),
        }),
    }

    for _, Child in ipairs(children) do
        table.insert(ChildList, Child)
    end

    return scope:New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 30),
        [seam.Children] = ChildList,
    })
end

function Builders.BuildTextInput(scope, inputRefs, jian, key, title, activeState, width)
    return Builders.RegisterInput(inputRefs, key, scope:New(jian.TextBox, {
        Title = title,
        Size = width or UDim2.fromScale(0.45, 1),
        Active = activeState,
    }))
end

function Builders.BuildCheckbox(scope, jian, title, activeState, valueState, width)
    return scope:New(jian.Checkbox, {
        Title = title,
        Size = width or UDim2.fromScale(0.45, 1),
        Active = activeState,
        Value = valueState,
    })
end

function Builders.BuildButton(scope, seam, jian, text, activeState, width, callback)
    return scope:New(jian.TextButton, {
        Text = text,
        Size = width or UDim2.fromScale(0.3, 1),
        Active = activeState,
        [seam.OnEvent "Activated"] = callback,
    })
end

function Builders.BuildSection(scope, seam, jian, text, children, parent, openByDefault)
    return scope:New(jian.ListSection, {
        Text = text,
        Parent = parent,
        OpenByDefault = openByDefault,
        [seam.Children] = children,
    })
end

return Builders
