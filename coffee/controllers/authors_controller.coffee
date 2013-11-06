module.exports.index = (socket, data) ->
  models = require('../document_models/models')

  models.WikipediaChangeLog.distinct "author", (err, result) =>
    socket.emit 'response', {
      controller: 'authors'
      method: 'index'
      body: result.length
    }

  redis = require "../redis/redis_subscriber"
  subscriber = new redis.RedisSubscriber '#en.wikipedia'

  subscriber.on 'message', (channel, message) ->
    models.WikipediaChangeLog.distinct "author", (err, result) =>
      socket.emit 'response', {
        controller: 'authors'
        method: 'index'
        body: result.length
      }
