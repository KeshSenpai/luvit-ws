local _ = require('math')
local a = require('string')
local b = require('table')
local c = {
    _VERSION = "sha.lua 0.5.0",
    _URL = "https://github.com/kikito/sha.lua",
    _DESCRIPTION = [[

   SHA-1 secure hash computation, and HMAC-SHA1 signature computation in Lua (5.1)

   Based on code originally by Jeffrey Friedl (http://regex.info/blog/lua/sha1)

   And modified by Eike Decker - (http://cube3d.de/uploads/Main/sha1.txt)

  ]],
    _LICENSE = [[

    MIT LICENSE



    Copyright (c) 2013 Enrique García Cota + Eike Decker + Jeffrey Friedl



    Permission is hereby granted, free of charge, to any person obtaining a

    copy of this software and associated documentation files (the

    "Software"), to deal in the Software without restriction, including

    without limitation the rights to use, copy, modify, merge, publish,

    distribute, sublicense, and/or sell copies of the Software, and to

    permit persons to whom the Software is furnished to do so, subject to

    the following conditions:



    The above copyright notice and this permission notice shall be included

    in all copies or substantial portions of the Software.



    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  ]]
}
local d = true
local e = 64
local f, g = _.floor, _.modf
local h, i, j = a.char, a.format, a.rep
local function k(I, J, K, L) return I * 0x1000000 + J * 0x10000 + K * 0x100 + L end
local function l(I)
    return f(I / 0x1000000) % 0x100, f(I / 0x10000) % 0x100,
           f(I / 0x100) % 0x100, I % 0x100
end
local function m(I, J)
    local K = 2 ^ (32 - I)
    local L, M = g(J / K)
    return L + M * K * (2 ^ (I))
end
local function n(I)
    if not d then return I end
    local J = {}
    for K = 0, 0xffff do
        local L, M = f(K / 0x100), K % 0x100
        J[K] = I(L, M)
    end
    return function(K, L) return J[K * 0x100 + L] end
end
local function o(I)
    local J = function(K)
        local L = f(I / K)
        return L % 2 == 1
    end
    return J(1), J(2), J(4), J(8), J(16), J(32), J(64), J(128)
end
local function p(I, J, K, L, M, N, O, P)
    local function Q(R, S) return R and S or 0 end
    return Q(I, 1) + Q(J, 2) + Q(K, 4) + Q(L, 8) + Q(M, 16) + Q(N, 32) +
               Q(O, 64) + Q(P, 128)
end
local q = n(function(I, J)
    local K, L, M, N, O, P, Q, R = o(J)
    local S, T, U, V, W, X, Y, Z = o(I)
    return p(K and S, L and T, M and U, N and V, O and W, P and X, Q and Y,
             R and Z)
end)
local r = n(function(I, J)
    local K, L, M, N, O, P, Q, R = o(J)
    local S, T, U, V, W, X, Y, Z = o(I)
    return p(K or S, L or T, M or U, N or V, O or W, P or X, Q or Y, R or Z)
end)
local s = n(function(I, J)
    local K, L, M, N, O, P, Q, R = o(J)
    local S, T, U, V, W, X, Y, Z = o(I)
    return p(K ~= S, L ~= T, M ~= U, N ~= V, O ~= W, P ~= X, Q ~= Y, R ~= Z)
end)
local function t(I) return 255 - (I % 256) end
local function u(I)
    return function(J, K)
        local L, M, N, O = l(J)
        local P, Q, R, S = l(K)
        return k(I(L, P), I(M, Q), I(N, R), I(O, S))
    end
end
local v = u(q)
local w = u(s)
local x = u(r)
local function y(I, ...)
    local J, K, L, M = l(I)
    for N = 1, select('#', ...) do
        local O, P, Q, R = l(select(N, ...))
        J, K, L, M = s(J, O), s(K, P), s(L, Q), s(M, R)
    end
    return k(J, K, L, M)
end
local function z(I, J, K)
    local L, M, N, O = l(I)
    local P, Q, R, S = l(J)
    local T, U, V, W = l(K)
    return k(r(L, r(P, T)), r(M, r(Q, U)), r(N, r(R, V)), r(O, r(S, W)))
end
local function A(I) return 4294967295 - (I % 4294967296) end
local function B(I, J) return (I + J) % 4294967296 end
local function C(I, ...)
    for J = 1, select('#', ...) do I = (I + select(J, ...)) % 4294967296 end
    return I
end
local function D(I) return i("%08x", I) end
local function E(I)
    return I:gsub('..', function(J) return a.char(tonumber(J, 16)) end)
end
local F = {}
local G = {}
for I = 0, 0xff do
    F[h(I)] = h(s(I, 0x5c))
    G[h(I)] = h(s(I, 0x36))
end
function c.sha1(I)
    local J, K, L, M, N = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476,
                          0xC3D2E1F0
    local O = #I * 8
    local P = h(0x80)
    local Q = #I + 1 + 8
    local R = Q % 64
    local S = R > 0 and j(h(0), 64 - R) or ""
    local T, U = g(O / 0x01000000)
    local V, W = g(0x01000000 * U / 0x00010000)
    local X, Y = g(0x00010000 * W / 0x00000100)
    local Z = 0x00000100 * Y
    local _a = h(0) .. h(0) .. h(0) .. h(0) .. h(T) .. h(V) .. h(X) .. h(Z)
    I = I .. P .. S .. _a
    assert(#I % 64 == 0)
    local aa = #I / 64
    local ba = {}
    local ca, da, ea, fa, ga, ha, ia, ja, ka
    local la = 0
    while la < aa do
        ca, la = la * 64 + 1, la + 1
        for na = 0, 15 do
            ba[na] = k(I:byte(ca, ca + 3))
            ca = ca + 4
        end
        for na = 16, 79 do
            ba[na] = m(1, y(ba[na - 3], ba[na - 8], ba[na - 14], ba[na - 16]))
        end
        da, ea, fa, ga, ha = J, K, L, M, N
        for na = 0, 79 do
            if na <= 19 then
                ia = x(v(ea, fa), v(A(ea), ga))
                ja = 0x5A827999
            elseif na <= 39 then
                ia = y(ea, fa, ga)
                ja = 0x6ED9EBA1
            elseif na <= 59 then
                ia = z(v(ea, fa), v(ea, ga), v(fa, ga))
                ja = 0x8F1BBCDC
            else
                ia = y(ea, fa, ga)
                ja = 0xCA62C1D6
            end
            da, ea, fa, ga, ha = C(m(5, da), ia, ha, ba[na], ja), da, m(30, ea),
                                 fa, ga
        end
        J, K, L, M, N = B(J, da), B(K, ea), B(L, fa), B(M, ga), B(N, ha)
    end
    local ma = D
    return ma(J) .. ma(K) .. ma(L) .. ma(M) .. ma(N)
end
function c.binary(I) return E(c.sha1(I)) end
function c.hmac(I, J)
    assert(type(I) == 'string', "key passed to sha1.hmac should be a string")
    assert(type(J) == 'string', "text passed to sha1.hmac should be a string")
    if #I > e then I = c.binary(I) end
    local K = I:gsub('.', G) .. a.rep(a.char(0x36), e - #I)
    local L = I:gsub('.', F) .. a.rep(a.char(0x5c), e - #I)
    return c.sha1(L .. c.binary(K .. J))
end
function c.hmac_binary(I, J) return E(c.hmac(I, J)) end
setmetatable(c, {__call = function(I, J) return c.sha1(J) end})
local H = {}
for I, J in pairs(c) do H[I] = J end
return H
