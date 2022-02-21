local rndm = require('rndm')
local base64 = require('base64')
local acceptKey = require('websocket-codec').acceptKey

require('websocket-codec').handshake = function(options, request)
    local key = rndm.base36(16)
    key = base64.encode(key)
    local host = options.host
    local path = options.path or "/"
    local protocol = options.protocol
    local req = {
        method = "GET",
        path = path,
        {"Connection", "Upgrade"},
        {"Upgrade", "websocket"},
        {"Sec-WebSocket-Version", "13"},
        {"Sec-WebSocket-Key", key},
        {
            "Sec-WebSocket-Extensions",
            "permessage-deflate; client_max_window_bits"
        }
    }
    for i = 1, #options do req[#req + 1] = options[i] end
    if host then req[#req + 1] = {"Host", host} end
    if protocol then req[#req + 1] = {"Sec-WebSocket-Protocol", protocol} end
    local res = request(req)
    if not res then return nil, "Missing response from server" end
    -- Parse the headers for quick reading
    if res.code ~= 101 then return nil, "response must be code 101" end

    local headers = {}
    for i = 1, #res do
        local name, value = unpack(res[i])
        headers[name:lower()] = value
    end

    if not headers.connection or headers.connection:lower() ~= "upgrade" then
        return nil, "Invalid or missing connection upgrade header in response"
    end
    if headers["sec-websocket-accept"] ~= acceptKey(key) then
        return nil, "challenge key missing or mismatched"
    end
    if protocol and headers["sec-websocket-protocol"] ~= protocol then
        return nil, "protocol missing or mistmatched"
    end
    return true
end

table.find = function(self, index)
    for i, v in next, self do if (i == index or v == index) then return i end end

    return nil
end

function string:split(d)
	local t = {}

	for c in self:gmatch(string.format('[^' .. tostring(d or '') .. ']+')) do
		table.insert(t, c)
	end

	return t
end

local path = package.loaded.path or require('path')
local cwd = require('uv').cwd()
local cwdSplit = cwd:split(path.sep)
local isWSDir = cwdSplit[#cwdSplit]:find('luvit-ws') ~= nil

_G.luvitwsrequire = function(module)
    if (isWSDir) then
        return require(path.join(cwd, 'src', table.unpack(module:split('/'))))
    end

    return require(path.join(cwd, 'deps', 'luvit-ws', 'src', table.unpack(module:split('/'))))
end

return {
    client = _G.luvitwsrequire("./websocket"),
    server = _G.luvitwsrequire("./websocketServer")
}
