	--转换256进制整数
	local ids1 = {}
	local ids2 = {}
	
	function _id2(a)
		local s1 = math.floor(a/256/256/256)%256
		local s2 = math.floor(a/256/256)%256
		local s3 = math.floor(a/256)%256
		local s4 = a%256
		local r = string.char(s1, s2, s3, s4)
		ids1[a] = r
		ids2[r] = a
		return r
	end

	function _id(a)
		return ids1[a] or _id2(a)
	end
	
	function __id2(a)
		local n1 = string.byte(a, 1)
		local n2 = string.byte(a, 2)
		local n3 = string.byte(a, 3)
		local n4 = string.byte(a, 4)
		local r = n1*256*256*256+n2*256*256+n3*256+n4
		ids2[a] = r
		ids1[r] = a
		return r
	end

	function __id(a)
		return ids2[a] or __id2(a)
	end

	--打印文本
	local oldprint = print
	function print(...)
		return oldprint('[' .. timer.time(true) .. ']', ...)
	end