local ws = require('./init')

local server = ws.server:new(3000)

function server:onListen()
    print('[SERVER] Waiting for client connections...')
end

function server:onConnect(client)
    print('Client Connected - ' .. client.uid)
end

function server:onDisconnect(client)
    print('Client Disconnected - ' .. client.uid)
end

function server:onMessage(client, message)
    print(client, message)
end

require('timer').setInterval(2000, function()
	coroutine.wrap(function()
		print('-- CONNECTED CLIENTS --\n')
		for i,v in next, server:getClients() do
			print(i,v,v.uid)
		end
	end)()
end)