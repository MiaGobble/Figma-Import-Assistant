local Packages = script.Parent.Parent.Packages
local PluginEssentials = require(Packages.PluginEssentials)

return function(ComponentName : string) : any
    local Component = PluginEssentials[ComponentName]

    if not Component then
        error("Component not found: " .. ComponentName)
        return
    end

    return Component :: any
end