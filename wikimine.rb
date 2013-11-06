# Load entire library. Right now, this order is important
require 'logger'
require 'redis'
require 'mongo'
require 'singleton'

Dir["#{File.dirname(__FILE__)}/lib/db/*.rb"].each { |f| load f }
Dir["#{File.dirname(__FILE__)}/lib/models/*.rb"].each { |f| load f }
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |f| load f }

def run!
  IrcScraper.new.start!
end

run! if __FILE__ == $0