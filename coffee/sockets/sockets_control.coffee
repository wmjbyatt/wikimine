SocketIO = require 'socket.io'

listen = (server) ->
  @io = SocketIO.listen(server)

  @io.sockets.on 'connection', (socket) =>
    socket.emit 'connected'

    socket.on 'request', (data) =>
      console.log data
      @router[data.controller][data.method](socket, data.body)

register_router = (router) ->
  @router = router

module.exports =
  'listen': listen
  'register_router': register_router
