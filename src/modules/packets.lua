local codec = require('websocket-codec')
local base64 = _G.luvitwsrequire('./modules/base64')
local json = _G.luvitwsrequire("./modules/json")
local sha1 = _G.luvitwsrequire('./modules/sha1')

local packets = {}
local insert, remove, concat = table.insert, table.remove, table.concat
local fmod, floor, frexp = math.fmod, math.floor, math.frexp

-- // -- -- // -- -- // -- -- // -- -- // -- 

local function str2bin (s)
	local b = {}

	for c in s:gmatch('.') do
		local n = c:byte()
		local d = {}

		for i=math.max(1, select(2, frexp(n))), 1, -1 do
			d[i] = fmod(n, 2)
			n = floor((n - d[i]) / 2)
		end

		insert(b, concat(d))
	end

	return concat(b)
end

-- // -- -- // -- -- // -- -- // -- -- // -- 

function packets:assemble(msg)
	return codec.encode(tostring(msg))
end

function packets:disassemble(chunk)
	local packet = codec.decode(chunk, 1)

	if (not packet) then return end

	return {
		payload = packet.payload,
		opcode = packet.opcode
	}
end

function packets:assembleHandshake(client, data)
	local headers = {}
	local headers_split = tostring(data):split('\r\n')

	remove(headers_split, 1)

	for i, header in ipairs(headers_split) do
		local header_split = header:split(': ')
		local key = remove(header_split, 1)
		local value = concat(header_split, ': ')

		pcall(function() value = json.parse(value) end)

		headers[key] = value
	end

	client.headers = headers

	local key = headers["Sec-WebSocket-Key"]

	if (not key) then
		return false
	end

	local d = concat({
		"HTTP/1.1 101 Switching Protocols",
		"Connection: Upgrade",
		"Upgrade: websocket",
		"Sec-WebSocket-Accept: " .. base64.encode(sha1.binary(key .. '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')),
		"",
		""
	}, "\r\n")

	client:write(d)

	return true
end

return packets