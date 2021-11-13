local events = require('core').Emitter
local initialized = false

local connections = {
	onConnect = nil,
	onDisconnect = nil,
	onMessage = nil,
	onError = nil,
	emit = function (self, ...)
		events:emit(...)
	end,
	send = function (self, data)
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
		elseif (initialized and key == "uninitialize") then
			return function ()
				initialized = false
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

events:on("clientConnect", function(...)
	if (type(connections.onConnect) == "function") then
		connections:onConnect(...)
	end
end)

events:on("clientDisconnect", function(...)
	if (type(connections.onDisconnect) == "function") then
		connections:onDisconnect(...)
	end
end)

events:on("clientMessage", function(...)
	if (type(connections.onMessage) == "function") then
		connections:onMessage(...)
	end
end)

events:on("clientError", function(...)
	if (type(connections.onError) == "function") then
		connections:onError(...)
	end
end)

return connections