module.exports.index = (socket, data) ->
  models = require('../document_models/models')

  models.WikipediaChangeLog.count (error, count) =>
    socket.emit 'response', {
      controller: 'default'
      method: 'index'
      body: count
    }

  subscriber = new require('../redis/redis_subscriber').RedisSubscriber "#en.wikipedia"
  


