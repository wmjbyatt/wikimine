require 'mongo'
require 'singleton'

class MongoConnection < Mongo::MongoClient
  include Singleton

end