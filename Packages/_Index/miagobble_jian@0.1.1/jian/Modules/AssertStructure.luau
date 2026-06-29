return function(Plugin, Seam)
    if not Plugin then
        error("Jian only works in a plugin environment")
    end

    if not Seam then
        error("Jian requires Seam to be in plugin directory")
    end
end
