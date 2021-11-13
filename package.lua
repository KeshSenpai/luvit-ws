  return {
    name = "luvit-ws",
    version = "1.0.0",
    description = "WebSocket Client Library",
    tags = { "ws", "websocket", "client" },
    license = "MIT",
    author = { name = "ayoko", email = "keshsenpai@gmail.com" },
    homepage = "https://github.com/luvit-ws",
    dependencies = {
      "luvit/secure-socket@1.2.3",
      "creationix/coro-split@v2.0.1",
      "creationix/coro-fs@v2.2.5",
      "creationix/coro-websocket@v3.1.1",
      "james2doyle/rndm"
    },
    files = {
      "**.lua",
      "!test*"
    }
  }
  