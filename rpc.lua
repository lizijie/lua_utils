
local tremove = table.remove

local chain = {}
rpc = setmetatable({}, {
    __index = function (_, k)
        chain[#chain+1] = k
        return rpc
    end,

    __call = function (_, ...)
        assert(#chain == 2)
        local fn = tremove(chain)
        local obj = tremove(chain)

        return _G[obj][fn](...)
    end
})


-- test case
rank_mgr = {}
function rank_mgr.get_rank_size()
    return 99
end

local sz = rpc.rank_mgr.get_rank_size()
assert(sz == 99)
