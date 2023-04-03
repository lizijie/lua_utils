
function table.diff (A, B)
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