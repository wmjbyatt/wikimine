# Establish Node server
app = require('http').createServer()
app.listen 8008

# Delegate Node server control to socket.io
sockets_control = require('./sockets/sockets_control')
sockets_control.listen(app)

# Build routing table
router =
  default: require('./controllers/default_controller')
  authors: require('./controllers/authors_controller')
  volume: require('./controllers/volume_controller')

# Register routing table with sockets_control
sockets_control.register_router router


