class RedisSubscriber
  redis = require('redis')

  constructor: (@channel) ->
    reference = this

    @client = redis.createClient()
    @client.subscribe(@channel)

  #Delegate on method to @client
  on: (event, callback) =>
    @client.on event, callback

module.exports =
  'RedisSubscriber': RedisSubscriber
