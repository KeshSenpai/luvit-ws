local events = require('core').Emitter
local initialized = false

local connections = {
	onConnect = nil,
	onDisconnect = nil,
	onMessage = nil,
	onListen = nil,
	emit = function (self, ...)
		events:emit(...)
	end,
	sendAll = function (self, data)
		error("Websocket is not initialized")
	end,
	disconnect = function (self)
		error('Websocket is not initialized')
	end
}

setmetatable(connections, {
	__index = function (self, key)
		if (not initialized and key == "initialize") then
			return function ()
				initialized = true
			end
		end
		return rawget(self, key)
	end,
	__newindex = function (self, key, value)
		if (initialized and (tostring(key) == "send" or tostring(key) == "disconnect")) then
			return nil
		end

		return rawset(self, key, value)
	end
})

events:on("serverListen", function(...)
	if (type(connections.onListen) == "function") then
		coroutine.wrap(connections.onListen)(connections, ...)
	end
end)

events:on("serverConnect", function(...)
	if (type(connections.onConnect) == "function") then
		coroutine.wrap(connections.onConnect)(connections, ...)
	end
end)

events:on("serverDisconnect", function(...)
	if (type(connections.onDisconnect) == "function") then
		coroutine.wrap(connections.onDisconnect)(connections, ...)
	end
end)

events:on("serverMessage", function(...)
	if (type(connections.onMessage) == "function") then
		coroutine.wrap(connections.onMessage)(connections, ...)
	end
end)

return connections