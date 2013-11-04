class RedisSubscriber
  redis = require('redis')

  constructor: (@channel) ->
    reference = this

    @client = redis.createClient()
    @client.subscribe(@channel)

    @client.on 'message', (channel, message) ->
      # We're going to refer to a property of RedisSubscriber here so that client code
      # can easily change this functionality
       reference.message_handler(message)


  message_handler: (message) ->
    console.log message



module.exports =
  'RedisSubscriber': RedisSubscriber
