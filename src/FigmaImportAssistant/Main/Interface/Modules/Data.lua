local Data = {}

local function ToNumber(value, fallback)
    local Number = tonumber(value)

    if Number == nil then
        return fallback
    end

    return Number
end

local function FindRootScreenGui(selected)
    if not selected then
        return nil
    end

    if selected:IsA("ScreenGui") then
        return selected
    end

    return selected:FindFirstAncestorWhichIsA("ScreenGui")
end

function Data.ApplySelectionToInputs(selected, inputRefs, settingValues)
    local Position = selected and (selected:GetAttribute("FigmaPosition") or Vector2.new(0, 0)) or Vector2.new(0, 0)
    local Size = selected and (selected:GetAttribute("FigmaSize") or Vector2.new(100, 100)) or Vector2.new(100, 100)

    if selected and selected:IsA("GuiObject") then
        if not selected:GetAttribute("FigmaPosition") then
            Position = Vector2.new(selected.Position.X.Offset, selected.Position.Y.Offset)
        end

        if not selected:GetAttribute("FigmaSize") then
            Size = Vector2.new(selected.Size.X.Offset, selected.Size.Y.Offset)
        end
    end

    local ShadowOffset = selected and (selected:GetAttribute("FigmaShadowOffset") or Vector2.new(0, 0)) or Vector2.new(0, 0)

    if inputRefs.XPosition then
        inputRefs.XPosition.Text = tostring(Position.X)
    end

    if inputRefs.YPosition then
        inputRefs.YPosition.Text = tostring(Position.Y)
    end

    if inputRefs.Width then
        inputRefs.Width.Text = tostring(Size.X)
    end

    if inputRefs.Height then
        inputRefs.Height.Text = tostring(Size.Y)
    end

    if inputRefs.Name then
        inputRefs.Name.Text = if selected then selected.Name else ""
    end

    if inputRefs.ImageId then
        if selected and (selected:IsA("ImageLabel") or selected:IsA("ImageButton")) then
            inputRefs.ImageId.Text = selected.Image:gsub("rbxassetid://", "")
        else
            inputRefs.ImageId.Text = ""
        end
    end

    if inputRefs.AnchorPointX then
        inputRefs.AnchorPointX.Text = if selected and selected:IsA("GuiObject") then tostring(selected.AnchorPoint.X) else "0"
    end

    if inputRefs.AnchorPointY then
        inputRefs.AnchorPointY.Text = if selected and selected:IsA("GuiObject") then tostring(selected.AnchorPoint.Y) else "0"
    end

    if inputRefs.StrokeThickness then
        inputRefs.StrokeThickness.Text = tostring(if selected then selected:GetAttribute("FigmaStrokeThickness") or 0 else 0)
    end

    if inputRefs.ShadowX then
        inputRefs.ShadowX.Text = tostring(ShadowOffset.X)
    end

    if inputRefs.ShadowY then
        inputRefs.ShadowY.Text = tostring(ShadowOffset.Y)
    end

    if inputRefs.ShadowSpread then
        inputRefs.ShadowSpread.Text = tostring(if selected then selected:GetAttribute("FigmaShadowSpread") or 0 else 0)
    end

    if inputRefs.ShadowRadius then
        inputRefs.ShadowRadius.Text = tostring(if selected then selected:GetAttribute("FigmaShadowRadius") or 0 else 0)
    end

    if not selected then
        return
    end

    settingValues.KeepAspectRatio.Value = selected:GetAttribute("FigmaSetting_IsAspectRatioConstrained")
    if settingValues.KeepAspectRatio.Value == nil then
        settingValues.KeepAspectRatio.Value = true
    end

    settingValues.ClipDescendants.Value = selected:GetAttribute("FigmaSetting_ClipDescendants")
    if settingValues.ClipDescendants.Value == nil then
        settingValues.ClipDescendants.Value = true
    end

    local RootGui = FindRootScreenGui(selected)

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

        for SettingName, MappingData in pairs(Mapping) do
            local AttributeName = MappingData[1]
            local DefaultValue = MappingData[2]
            local Value = RootGui:GetAttribute(AttributeName)

            if Value == nil then
                Value = DefaultValue
            end

            settingValues[SettingName].Value = Value
        end
    end
end

function Data.CollectApplyData(selected, readText, settingValues)
    local PositionAttribute = selected and selected:GetAttribute("FigmaPosition") or Vector2.new(0, 0)
    local SizeAttribute = selected and selected:GetAttribute("FigmaSize") or Vector2.new(100, 100)
    local ShadowOffset = selected and selected:GetAttribute("FigmaShadowOffset") or Vector2.new(0, 0)

    return {
        Size = {
            X = ToNumber(readText("Width"), SizeAttribute.X),
            Y = ToNumber(readText("Height"), SizeAttribute.Y),
        },
        Position = {
            X = ToNumber(readText("XPosition"), PositionAttribute.X),
            Y = ToNumber(readText("YPosition"), PositionAttribute.Y),
        },
        AnchorPoint = {
            X = ToNumber(readText("AnchorPointX"), if selected and selected:IsA("GuiObject") then selected.AnchorPoint.X else 0),
            Y = ToNumber(readText("AnchorPointY"), if selected and selected:IsA("GuiObject") then selected.AnchorPoint.Y else 0),
        },
        Name = if readText("Name") ~= "" then readText("Name") else if selected then selected.Name else "",
        Image = readText("ImageId"),
        Stroke = ToNumber(readText("StrokeThickness"), if selected then selected:GetAttribute("FigmaStrokeThickness") or 0 else 0),
        Oblique = 0,
        Settings = {
            IsAspectRatioConstrained = settingValues.KeepAspectRatio.Value,
            ClipDescendants = settingValues.ClipDescendants.Value,
            ImportFramesAsFrames = settingValues.ImportFramesAsFrames.Value,
            ImportTextAsText = settingValues.ImportTextAsText.Value,
            ImportStrokesAsUIStroke = settingValues.ImportStrokesAsUIStroke.Value,
            ApplyBackgroundColor = settingValues.ApplyBackgroundColor.Value,
            ApplyAutoLayout = settingValues.ApplyAutoLayout.Value,
            RespectAutoImportCornerRadius = settingValues.RespectCornerRadius.Value,
            RespectAutoImportFrameOpacity = settingValues.RespectFrameOpacity.Value,
        },
        Shadow = {
            Offset = Vector2.new(
                ToNumber(readText("ShadowX"), ShadowOffset.X),
                ToNumber(readText("ShadowY"), ShadowOffset.Y)
            ),
            Spread = ToNumber(readText("ShadowSpread"), if selected then selected:GetAttribute("FigmaShadowSpread") or 0 else 0),
            Radius = ToNumber(readText("ShadowRadius"), if selected then selected:GetAttribute("FigmaShadowRadius") or 0 else 0),
        },
    }
end

function Data.ApplyImportSettingsToRoot(seam, rootGui, settingValues)
    if not rootGui then
        return
    end

    seam.New(rootGui, {
        [seam.Attribute("FigmaSetting_IsAspectRatioConstrained")] = settingValues.KeepAspectRatio.Value,
        [seam.Attribute("FigmaSetting_ImportFramesAsFrames")] = settingValues.ImportFramesAsFrames.Value,
        [seam.Attribute("FigmaSetting_ImportTextAsText")] = settingValues.ImportTextAsText.Value,
        [seam.Attribute("FigmaSetting_ImportStrokesAsUIStroke")] = settingValues.ImportStrokesAsUIStroke.Value,
        [seam.Attribute("FigmaSetting_ApplyBackgroundColor")] = settingValues.ApplyBackgroundColor.Value,
        [seam.Attribute("FigmaSetting_ApplyAutoLayout")] = settingValues.ApplyAutoLayout.Value,
        [seam.Attribute("FigmaSetting_RespectAutoImportCornerRadius")] = settingValues.RespectCornerRadius.Value,
        [seam.Attribute("FigmaSetting_RespectAutoImportFrameOpacity")] = settingValues.RespectFrameOpacity.Value,
    })
end

return Data
