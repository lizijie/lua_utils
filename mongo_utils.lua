
local function check_key_type(k)
    local kt = type(k)
    assert(kt == "string" or "kt" == "number",
        string.format("Only Support key type of [string, number]. k:%s", k))
    return  kt
end

local function check_value_type(v)
    local vt = type(v)
    assert(vt == "string" or vt == "number" or vt == "table",
        string.format("Only Support value type of [string, number, table] v:%s", v))
    return vt
end

local function __mongo(data)
    local db_data = {}

    for k, v in pairs(data) do
        local kt = check_key_type(k)
        local vt = check_value_type(v)
        
        local k2 = k
        local v2 = v
        if kt == "number" then
            k2 = tostring(k)
        end

        assert(kt == "string" and tonumber(kt) == nil, "Not Support a digit is string type")

        if vt == "table" then
            local seri_fn = v.__serialize
            if seri_fn ~= nil and type(seri_fn) == "function" then
                local ok, tb = pcall(seri_fn, v)
                assert(ok, tb)
                assert(type(tb) == "table", "embed calss:__serialize must return a table")
                v2 = __mongo(tb)
            else
                v2 = __mongo(v)
            end
        end

        db_data[k2] = v2
    end

    return db_data
end

local function __lua(db_data)
    local data = {}
    for k, v in pairs(db_data) do
        local kt = check_key_type(k)
        local vt = check_value_type(v)

        local k2 = tonumber(k) or k
        local v2 = v

        if vt == "table" then
            v2 = __lua(v)
        end

        data[k2] = v2
    end

    return data
end

local mongo_utils = {}

function mongo_utils.to_mongo(data)
    if data == nil or next(data) == nil then
        return nil
    end

    local db_data = __mongo(data)
    return db_data
end

function mongo_utils.to_lua(db_data)
    if db_data == nil or next(db_data) == nil then
        return nil
    end

    return __lua(db_data)
end

return mongo_utils
