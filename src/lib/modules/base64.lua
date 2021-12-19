local _ = require('string')
local a = {}
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
a.encode = function(c)
    return ((c:gsub('.', function(d)
        local e, f = '', d:byte()
        for g = 8, 1, -1 do
            e = e .. (f % 2 ^ g - f % 2 ^ (g - 1) > 0 and '1' or '0')
        end
        return e
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(d)
        if (#d < 6) then return '' end
        local e = 0
        for f = 1, 6 do e = e + (d:sub(f, f) == '1' and 2 ^ (6 - f) or 0) end
        return b:sub(e + 1, e + 1)
    end) .. ({'', '==', '='})[#c % 3 + 1])
end
a.decode = function(c)
    c = _.gsub(c, '[^' .. b .. '=]', '')
    return (c:gsub('.', function(d)
        if (d == '=') then return '' end
        local e, f = '', (b:find(d) - 1)
        for g = 6, 1, -1 do
            e = e .. (f % 2 ^ g - f % 2 ^ (g - 1) > 0 and '1' or '0')
        end
        return e
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(d)
        if (#d ~= 8) then return '' end
        local e = 0
        for f = 1, 8 do e = e + (d:sub(f, f) == '1' and 2 ^ (8 - f) or 0) end
        return _.char(e)
    end))
end
return {encode = a.encode, decode = a.decode}
