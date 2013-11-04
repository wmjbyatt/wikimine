# Establish Node server
app = require('http').createServer()
app.listen 8008

# Delegate Node server control to socket.io
sockets_control = require('./sockets/sockets_control').listen(app)