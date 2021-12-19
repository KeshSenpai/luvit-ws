local b = _G.luvitwsrequire('./modules/bitmap')
local c = require('bit')
local d = _G.luvitwsrequire('./modules/bytemap')
local e = _G.luvitwsrequire("./modules/base64")
local f = _G.luvitwsrequire("./modules/sha1")
local g = require("string")
local json = _G.luvitwsrequire("./modules/json")
g.split = function(k, l)
    if l == nil then l = "%s" end
    local m = {}
    local n = 1
    for o in g.gmatch(k, "([^" .. l .. "]+)") do
        m[n] = o
        n = n + 1
    end
    return m
end
local function h(k)
    local l = d.fromString(k)
    local m = b.fromNumber(l[1])
    local n = m:isSet(1)
    local o = m:isSet(2)
    _ = m:isSet(3)
    a = m:isSet(4)
    local p = tonumber(m[5] .. m[6] .. m[7] .. m[8], 2)
    if not (n or o or _ or a) then
        print("WebSocket Error: Message Fragmentation not supported.")
        return
    end
    if p == 8 then return 2 end
    if p == 9 then
        m[8] = true
        m[7] = false
        l[1] = m:toNumber()
        return 1, l:toString()
    end
    l:popStart()
    local q = l[1] - 128
    l:popStart()
    if q == 126 then
        q = l:toNumber(1, 2)
        l:popStart(2)
    elseif q == 127 then
        q = l:toNumber(1, 2, 3, 4, 5, 6, 7, 8)
        l:popStart(8)
    end
    local r = {l:get(1, 2, 3, 4)}
    l:popStart(4)
    if q > #l.bytes then return 3 end
    local s = ""
    l:forEach(function(t, u)
        local v = t % 4
        s = s .. g.char(c.bxor(r[v > 0 and v or 4], u))
    end)
    return s
end
local function i(k)
    local l = "10000001"
    local m = d.new({tonumber(l, 2), #k})
    if m[2] >= 65536 then
        local o = m[2]
        for p = 10, 3, -1 do
            m[p] = c.band(o, 0xFF)
            o = c.rshift(o, 8)
        end
        m[2] = 127
    elseif m[2] >= 126 then
        m[4] = c.band(m[2], 0xFF)
        m[3] = c.band(c.rshift(m[2], 8), 0xFF)
        m[2] = 126
    end
    for o = 1, #k do m:push(g.byte(k:sub(o, o))) end
    local n = ""
    m:forEach(function(o, p) n = n .. g.char(p) end)
    return n
end
local function j(c, k)
    local l = k:split('\r\n')
    local m = l[1]
    l[1] = nil
    local n = {}
    for p, q in pairs(l) do
        if #q > 2 then
            local r = q:split(": ")
            local key = table.remove(r, 1)
            local value = table.concat(r, ': ')
            pcall(function() value = json.parse(value) end)

            n[key] = value
        end
    end

    c.headers = n

    if (not n["Sec-WebSocket-Key"]) then
        return false
    end
    
    local o = n["Sec-WebSocket-Key"] .. '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'
    o = e.encode(f.binary(o))
    c:write("HTTP/1.1 101 Switching Protocols\r\n" .. "Connection: Upgrade\r\n" ..
            "Upgrade: websocket\r\n" .. "Sec-WebSocket-Accept: " .. o .. "\r\n" ..
            "\r\n")

    return true
end
return {
    disassemblePacket = h,
    assembleHandshakeResponse = j,
    assemblePacket = i
}
