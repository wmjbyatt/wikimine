class RedisPublisher
  def initialize(channel)
    @client = Redis.new
    @channel = String channel
  end

  def publish(message)
    @client.publish @channel, message
  end
end