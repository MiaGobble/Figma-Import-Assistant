-- Services
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    return
end

-- Imports
local Packages = script.Parent.Packages
local Seam = require(Packages.Seam)
local Jian = require(Packages.Jian)
local Interface = require(script.Interface)
local CorrectionHandler = require(script.CorrectionHandler)
local ImageMapper = require(script.ImageMapper)

local function Init()
    local Scope = Seam.Scope(Seam)

    local Toolbar = Scope:New(Jian.Toolbar, {
        Name = "Figma Import Assistant",
    })

    local Button = Scope:New(Jian.ToolbarButton, {
        Toolbar = Toolbar,
        Active = true,
        ToolTip = "Open Figma Import Assistant",
        Image = "rbxassetid://17426758390",
        Name = "Open",
    })
    
    Interface.Init()
    ImageMapper.Init()
    CorrectionHandler:Init()
    
    Button.Click:Connect(function()
        Interface.ToggleVisibility()
    end)

    Interface.OnOpenImageMapper(function()
        ImageMapper.Toggle()
    end)
end

Init()