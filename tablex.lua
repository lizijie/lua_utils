
EMPTY_TABLE_MT = {__newindex = function () error("Can't not Modfiy EMPTY_TABLE") end}
EMPTY_TABLE = setmetatable({}, EMPTY_TABLE_MT)

function table.dump(tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		local sb = {}
		table.insert(sb, "{\n")
		for key, value in pairs (tt) do
			table.insert(sb, string.rep (" ", indent + 2)) -- indent it
			table.insert(sb, tostring(key) .. " = ")

			if type (value) == "table" then
				if not done[value] then
			  		done [value] = true
			  		table.insert(sb, table.dump (value, indent + 2, done) .. tostring(value) .. ",\n")
				else
			  		table.insert(sb, tostring(value) .. ",\n")
				end
			elseif "string" == type(value) then
			  table.insert(sb, "\"" .. value .. "\",\n")
			else
			  table.insert(sb, tostring(value) .. ",\n")
			end
	 	end
	  	table.insert(sb, string.rep(" ", indent)) -- indent it
	  	table.insert(sb, "}")
	  	return table.concat(sb)
	else
	  	return tt .. "\n"
	end
end

-- @ref https://github.com/martinfelis/luatablediff
function table.diff(A, B)
	local diff = { del = {}, mod = {}, sub = {} }

	for k,v in pairs(A) do
		if type(A[k]) == "function" or type(A[k]) == "userdata" then
			error ("diff only supports diffs of tables!")
		elseif B[k] ~= nil and type(A[k]) == "table" and type(B[k]) == "table" then
			diff.sub[k] = table.diff(A[k], B[k])

			if next(diff.sub[k]) == nil then
				diff.sub[k] = nil
			end
		elseif B[k] == nil then
			diff.del[#(diff.del) + 1] = k
		elseif B[k] ~= v then
			diff.mod[k] = B[k]
		end
	end

	for k,v in pairs(B) do
		if type(B[k]) == "function" or type(B[k]) == "userdata" then
			error ("diff only supports diffs of tables!")
		elseif diff.sub[k] ~= nil then
			-- skip	
		elseif A[k] ~= nil and type(A[k]) == "table" and type(B[k]) == "table" then
			diff.sub[k] = table.diff(B[k], A[k])

			if next(diff.sub[k]) == nil then
				diff.sub[k] = nil
			end
		elseif B[k] ~= A[k] then
			diff.mod[k] = v
		end
	end

	if next(diff.sub) == nil then
		diff.sub = nil
	end

	if next(diff.mod) == nil then
		diff.mod = nil
	end

	if next(diff.del) == nil then
		diff.del = nil
	end

	return diff
end

function table.is_array(tb)
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

function table.size(t)
    local i = 0
    for _ in pairs(t) do i = i + 1 end
    return i
end