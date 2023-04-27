
require("tablex")

sys_print = print

function print(...)
    local params = table.pack(...)
    local list = {}
    for i = 1, params.n, 1 do
        local v = params[i]
        if type(v) == "table" then
            local s = table.dump(v)
            list[#list+1] = s
        else
            list[#list+1] = tostring(v)
        end
    end
   
    local str = table.concat(list, " ")
    sys_print(str)
end