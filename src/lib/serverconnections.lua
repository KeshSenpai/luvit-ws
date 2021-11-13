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
		connections:onListen(...)
	end
end)

events:on("serverConnect", function(...)
	if (type(connections.onConnect) == "function") then
		connections:onConnect(...)
	end
end)

events:on("serverDisconnect", function(...)
	if (type(connections.onDisconnect) == "function") then
		connections:onDisconnect(...)
	end
end)

events:on("serverMessage", function(...)
	if (type(connections.onMessage) == "function") then
		connections:onMessage(...)
	end
end)

return connections