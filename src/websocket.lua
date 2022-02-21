local cWS = require('coro-websocket')
local parseUrl = cWS.parseUrl
local connect = cWS.connect
local connections = _G.luvitwsrequire('./connections')

local websocket = {}
local connected = false
local isconnecting = false

function websocket:connect(url)
	if (isconnecting) then return end
	isconnecting = true

	function connections:reconnect()
		if (not connected) then
			websocket:connect(url)
		end
	end

	coroutine.wrap(function()
		assert(type(url) == "string", '"url" must be a string')
		local options, err = parseUrl(url)

		if (err) then return error(err) end

		if (options.pathname == '') then
			options.pathname = '/'
		end

		options.heartbeat = 1000

		local success, out = pcall(function()
			local res, read, write = connect(options)
			if (not res or type(read) ~= "function") then
				isconnecting = false
				return connections:emit("clientError", res or read or write)
			end

			function connections:send(data)
				coroutine.wrap(write)({ payload = tostring(data) })
			end

			function connections:disconnect()
				connected = false
				require('uv').close(res.socket)
			end

			connections.initialize()

			isconnecting = false
			connected = true
			connections:emit('clientConnect')

			while (true) do
				local response = read()

				if (not response) then
					connected = false
					connections:emit("clientDisconnect", "Websocket connection has been lost")
					connections.uninitialize()
					return
				end

				connections:emit('clientMessage', response.payload)
			end
		end)

		if (not success) then
			connections:emit('clientError', out)
			isconnecting = false
		end
	end)()

	return connections
end

return websocket