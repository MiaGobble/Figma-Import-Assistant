return function(PropertiesTable : {[any] : any}, PropertiesStripped : {any})
    local Clone = table.clone(PropertiesTable)

    for _, StrippedIndex in PropertiesStripped do
        Clone[StrippedIndex] = nil
    end

    return Clone
end
