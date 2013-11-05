SocketIO = require 'socket.io'

listen = (server) ->
  @io = SocketIO.listen(server)

  @io.sockets.on 'connection', (socket) =>
    socket.emit 'connected'

    for route, action of @router
      socket.on route, (data) ->
        action(socket, data)

register_router = (router) ->
  @router = router

module.exports =
  'listen': listen
  'register_router': register_router
