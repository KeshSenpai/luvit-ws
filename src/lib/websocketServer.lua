local net = require("net")
local wsu = _G.luvitwsrequire("./modules/websocketutils")
local connections = _G.luvitwsrequire('./serverconnections')

local server = {}

function server:new()
	coroutine.wrap(function()
		local clients = {}

		local _server = net.createServer(function(client)
			client.oldBuffer = ''
			client:on("data", function (data)
				if (data:sub(1, 3) == "GET") then
					function client:send(msg)
						client:write(wsu.assemblePacket(msg))
					end

					if (not wsu.assembleHandshakeResponse(client, data)) then
						return client:_end()
					end

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

		function connections:close()
			connections:exit()
		end

		function connections:listen(port)
			_server:listen(port)
			connections.listen = nil
			connections:emit("serverListen")
		end

		connections.initialize()
	end)()

	return connections
end

return server