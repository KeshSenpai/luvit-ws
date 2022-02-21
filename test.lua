local ws = require('./init')

local server = ws.server:new()

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
    print(string.format('[CLIENT - %s] [Message - "%s"]', client.uid, message))
end

server:listen(8000)