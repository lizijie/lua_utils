
local tremove = table.remove

-- local chain = {}
-- rpc = setmetatable({}, {
--     __index = function (_, k)
--         chain[#chain+1] = k
--         return rpc
--     end,

--     __call = function (_, ...)
--         assert(#chain == 2)
--         local fn = tremove(chain)
--         local obj = tremove(chain)

--         return _G[obj][fn](...)
--     end
-- })


-- -- test case
rank_mgr = {}
function rank_mgr.get_rank_size()
    return 99
end

-- local sz = rpc.rank_mgr.get_rank_size()
-- assert(sz == 99)


-- second
local chain = {}
rpc = {
    __index = function (t, k)
        chain[#chain+1] = k
        return t
    end,

    __call = function (t, ...)
        assert(#chain == 3)
        local fn = tremove(chain)
        local obj = tremove(chain)
        local type = tremove(chain)

        print(t.node_type, type, obj, fn)

        return _G[obj][fn](...)
    end
}


center = setmetatable({node_type=1}, rpc)
game = setmetatable({node_type=2}, rpc)

center.send.rank_mgr.get_rank_size()
center.call.rank_mgr.get_rank_size()

game.send.rank_mgr.get_rank_size()
game.call.rank_mgr.get_rank_size()