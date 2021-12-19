local ws = require('./init')

local client = ws.client:connect('ws://localhost:8000') -- supports wss too

function client:onConnect()
    print('[CLIENT] Connected')
end

function client:onMessage(message)
    print(message)
end

function client:onError(message)
	print(message)
	client:reconnect()
end

function client:onDisconnect()
    print('[CLIENT] Disconnected')
    require('timer').setTimeout(1000, function()
        coroutine.wrap(function()
			client:reconnect()
		end)()
    end)
end