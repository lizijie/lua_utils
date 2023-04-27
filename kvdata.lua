require("printx")

local function _split_path(str)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)%."
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t, cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
end

local function _is_array(tb)
	if type(tb) ~= "table" then

		return false
	end

	local i = 0
	for _ in pairs(tb) do
		i = i + 1
		if tb[i] == nil then
			return false
		end
	end

	return true
end

local function _table_size(t)
    local i = 0
    for _ in pairs(t) do i = i + 1 end
    return i
end

local M = {}
M.__index = M

function M.new()
    local obj = {
        data = {},
    }
    setmetatable(obj, M)
    return obj
end

function M:new_item(name, opt)
    local expire = 0
    if opt ~= nil then
        if opt.expire ~= nil and opt.expire > 0 then
            expire = os.time() + expire
        end
    end

    return {
        _id = name,
        expire = expire,
        map = {},
    }
end

function M:get(name, path)
    local item = self.data[name]
    if item == nil then
        return nil
    end

    -- 查看数据是否过期
    local expire = item.expire
    if expire > 0 then
        local now = os.time()
        if now >= expire then
            item.map = {}
        end
    end

    local result = item.map
    -- 循环嵌套key查询
    if path ~= nil and path ~= "" then
        local keys = _split_path(path)
        local keys_sz = #keys
        if keys_sz > 0 then
            for _, k in ipairs(keys) do
                result = result[k]
                if result == nil then
                    break
                end
            end
        end
    end

    return result
end

function M:set(name, path, v, opt)
    assert(path ~= nil and path ~= "")

    local row = self.data[name]
    if row == nil then
        row = self:new_item(name, opt)
        self.data[name] = row
    end

    local keys = _split_path(path)
    local keys_sz = #keys

    local map = row.map
    for i = 1, keys_sz do
        local k = keys[i]
        if i ~= keys_sz then
            map[k] = map[k] or {}
            map = map[k]
        else
            -- 如果到最后一个key，则赋值
            map[k] = v
        end
    end

    return 0
end

function M:del(name, path)
    local row = self.data[name]
    if row == nil then
        return -1
    end

    if path == nil then
        self.data[name] = nil
        return
    end

    local keys = _split_path(path)
    local keys_sz = #keys
    assert(keys_sz > 0)

    local map = row.map
    for i = 1, keys_sz do
        local k = keys[i]
        if i ~= keys_sz then
            map = map[k]
            if map == nil then
                break
            end
        else
            map[k] = nil
        end
    end

    return 0
end

function M:size(name, path)
    local result = self:get(name, path)
    if result == nil then
        return 0
    end

    local sz = _table_size(result)
    return sz
end

function M:lpush(name, path, v)
    assert(path ~= nil and path ~= "")

    local list = self:get(name, path)
    if list == nil then
        self:set(name, path, {})
        list = self:get(name, path)
    end
    if list == nil then
        return -1
    end
    assert( _is_array(list))

    table.insert(list, 1, v)
end

function M:lpop(name, path)
    assert(path ~= nil and path ~= "")

    local list = self:get(name, path)
    if list == nil then
        return -1
    end
    assert(_is_array(list))

    local v = table.remove(list, 1)
    return v
end

function M:rpush(name, path, v)
    assert(path ~= nil and path ~= "")

    local list = self:get(name, path)
    if list == nil then
        self:set(name, path, {})
        list = self:get(name, path)
    end
    if list == nil then
        return -1
    end
    assert(_is_array(list))

    list[#list+1] = v
    return 0
end

function M:rpop(name, path)
    assert(path ~= nil and path ~= "")

    local list = self:get(name, path)
    if list == nil then
        return -1
    end
    assert(_is_array(list))

    local v = table.remove(list)
    return v
end

function M:lrem(name, path, index)
    assert(path ~= nil and path ~= "")
    assert(type(index) == "number")

    local list = self:get(name, path)
    if list == nil then
        return -1
    end
    assert(_is_array(list))

    table.remove(list, index)

    return 0
end

function M:llen(name, path)
    assert(path ~= nil and path ~= "")

    local list = self:get(name, path)
    if list == nil then
        return -1
    end
    assert(_is_array(list))

    return #list
end

-- test case
local obj =  M.new()

obj:rpush("test_db", "a.b.c", 1)
assert(obj:size("test_db", "a") == 1)
assert(obj:size("test_db", "a.b") == 1)
assert(obj:size("test_db", "a.b.c") == 1)
assert(obj:get("test_db").a.b.c[1] == 1)

obj:lpush("test_db", "a.b.c", 2)
assert(obj:get("test_db").a.b.c[1] == 2)
assert(obj:size("test_db", "a.b.c") == 2)

obj:lpush("test_db", "a.b.c", 3)
assert(obj:llen("test_db", "a.b.c") == 3)
assert(obj:size("test_db", "a.b.c") == 3)

obj:lpop("test_db", "a.b.c")
assert(obj:get("test_db", "a.b.c")[1] == 2)

obj:rpop("test_db", "a.b.c")
assert(obj:get("test_db", "a.b.c")[1] == 2)
assert(obj:llen("test_db", "a.b.c") == 1)

obj:lrem("test_db", "a.b.c", 1)
assert(obj:llen("test_db", "a.b.c") == 0)

obj:del("test_db", "a.b")
assert(obj:get("test_db", "a.b") == nil)
assert(obj:get("test_db", "a").b == nil)

obj:set("test_db", "a", nil)
assert(obj:get("test_db", "a") == nil)
assert(obj:size("test_db", "a") == 0)
