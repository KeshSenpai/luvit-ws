local net = require("net")
local wsu = require("websocketutils")
local connections = require('./serverconnections')

local server = {}

function server:new(port)
	coroutine.wrap(function()
		local clients = {}

		local _server = net.createServer(function(client)
			client.oldBuffer = ''

			client:emit("serverListen")

			client:on("data", function (data)
				if (data:sub(1, 3) == "GET") then
					function client:send(msg)
						client:write(wsu.assemblePacket(msg))
					end

					client:write(wsu.assembleHandshakeResponse(data))

					table.insert(clients, client)

					for _index, _client in next, clients do
						_client.id = _index
					end

					client.uid = require('base64').encode(require('rndm').base62(48))

					connections:emit("serverConnect", client)
				else
					local message, v = wsu.disassemblePacket(client.oldBuffer .. data)

					if (message == 3) then
						client.oldBuffer = client.oldBuffer .. data
					elseif (message == 2) then
						connections:emit("serverDisconnect", client)
						table.remove(clients, client.id)
					elseif (message == 1) then
						client:write(v)
					elseif (message) then
						connections:emit("serverMessage", client, message)
						client.oldBuffer = ""
					end
				end
			end)

			client:on("close", function() client:disconnect() end)

			client:on("disconnect", function() client:disconnect() end)

			client:on('end', function() client:disconnect() end)

			function client:disconnect()
				if (table.find(clients, client)) then
					connections:emit("serverDisconnect", client)
					table.remove(clients, client.id)
					client:_end()
				end
			end
		end)

		function connections:getClients()
			return {table.unpack(clients)}
		end

		function connections:sendAll(message)
			for _, client in next, clients do
				client:send(message)
			end
		end

		function connections:exit()
			for _, client in next, clients do
				client:_end()
			end

			_server:close()
		end

		connections.initialize()

		_server:listen(port)
	end)()

	return connections
end

return server
