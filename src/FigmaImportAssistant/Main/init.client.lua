local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    return
end

local Interface = require(script.Interface)
local Component = require(script.Component)
local CorrectionHandler = require(script.CorrectionHandler)

local Plugin = plugin

local Toolbar = Component "Toolbar" {
    Name = "Figma Import Assistant",
}

local Button = Component "ToolbarButton" {
    Toolbar = Toolbar,
    Active = true,
    ToolTip = "Open Figma Import Assistant",
    Image = "rbxassetid://17426758390",
    Name = "Open",
}

Interface:Init()
CorrectionHandler:Init()

Button.Click:Connect(function()
    Interface:ToggleVisibility()
end)