local net = require("net")
local connections = _G.luvitwsrequire('./serverconnections')
local packets = _G.luvitwsrequire('./modules/packets')
local encode = require('websocket-codec').encode

local find, insert, remove = table.find, table.insert, table.remove

local server = {}

function server:new()
	coroutine.wrap(function()
		local clients = {}

		local _server = net.createServer(function(client)
			client:nodelay(true)

			client:on("data", function (data)
				if (data:sub(1, 3) == "GET") then
					if (not packets:assembleHandshake(client, data)) then
						return client:_end()
					end

					insert(clients, client)

					for _index, _client in next, clients do
						_client.id = _index
					end

					client.uid = require('base64').encode(require('rndm').base62(48))

					connections:emit("serverConnect", client)
				else
					local packet = packets:disassemble(data)

					if (not (packet and type(find(clients, client)) == 'number')) then return end

					local op = packet.opcode
					local pl = packet.payload

					if (op == 9) then
						client:write(encode({ opcode = 0xA, payload = 'pong' }))
					elseif (op == 3) then
						-- client.oldBuffer = data
					elseif (op == 2) then
						client:disconnect()
						connections:emit("serverDisconnect", client)
					elseif (op == 1) then
						connections:emit("serverMessage", client, pl)
					else
					end
				end
			end)

			client:on("close", function() client:disconnect() end)

			client:on("disconnect", function() client:disconnect() end)

			client:on('end', function() client:disconnect() end)

			function client:send(msg)
				client:write(packets:assemble(msg))
			end

			function client:disconnect()
				if (find(clients, client)) then
					connections:emit("serverDisconnect", client)
					remove(clients, find(clients, client))
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