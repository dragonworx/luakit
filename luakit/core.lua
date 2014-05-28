table.indexOf = function( t, object )
    if "table" == type( t ) then
        for i = 1, #t do
            if object == t[i] then
                return i
            end
        end
    else
        error("table.indexOf expects table for first argument")
    end
end

require("luakit.console")
require("luakit.expect")
require("luakit.class")
require("luakit.component")