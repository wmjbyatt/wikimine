module.exports.index = (socket, data) ->
  models = require('../document_models/models')

  models.WikipediaChangeLog.count (error, count) =>
    @count = count

    socket.emit 'response', {
      controller: 'default'
      method: 'index'
      body: @count
    }

  redis = require('../redis/redis_subscriber')
  subscriber = new redis.RedisSubscriber "#en.wikipedia"

  subscriber.on 'message', (channel, message) =>
    @count++

    socket.emit 'response', {
      controller: 'default'
      method: 'index'
      body: @count
    }

