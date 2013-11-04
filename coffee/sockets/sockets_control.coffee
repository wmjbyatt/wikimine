SocketIO = require 'socket.io'

listen = (server) ->
  io = SocketIO.listen(server)

  io.sockets.on 'connection', (socket) ->
    socket.emit 'registered'

module.exports =
  'listen': listen
