class Document
  #
  # EXCEPTION CLASSES
  #
  class InvalidKeyError < StandardError; end

  #
  # CLASS METHODS
  #
  def self.connection
    MongoConnection.instance
  end

  def self.set_database(db)
    @@database = self.connection.db(db.to_s)
  end

  def self.database
    @@database
  rescue NameError
    self.set_database :default
  end

  def self.set_collection(col)
    @@col = self.database.collection(col.to_s)
  end

  def self.collection
    @@col
  rescue NameError
    self.set_collection self.name
  end

  def self.find(query)
    self.collection.find(query).map do |row|
      instance = self.allocate
      instance.send :initialize!, row
    end
  end
  #
  # INSTANCE METHODS
  #
  def initialize(data = Hash.new)
    raise TypeError, "Inappropiate data type for document store" unless data.respond_to? :[]
    raise InvalidKeyError, "Cannot initialize a document with an _id key" if data.keys.map(&:to_s).include? '_id'

    self.initialize!(data)
  end

  def [](key)
    @document[key]
  end

  def []=(key, value)
    raise InvalidKeyError if key.to_s == '_id' # Make sure we're not futzing with Mongo _id's

    @document[key] = value
  end

  def delete_key(key)
    @document.delete(key)
  end

  def save
    if @document.keys.include? '_id'
      #
      # We're going to do full document updates here. Eventually we'd want atomic updates, but that's beyond the
      # immediate scope.
      #
      @collection.update(
        {'_id' => @collection['_id']},
        @document
      )
    else
      #
      # Insert, grab object id and assign it to object
      #
      id = @collection.insert @document
      @document['_id'] = id
    end
  end

  def inspect
    #
    # Hide other instance variables from inspect
    #
    "<#{self.class.name}:#{self.object_id} @document=#{@document.inspect}>"
  end

  def method_missing(method, *args, &block)
    if match_data = method.to_s.match(/(.+)=\z/)
      self[match_data[1].to_sym] = *args
    else
      self[method]
    end
  end

  #
  # PROTECTED/PRIVATE
  #
  protected

  def initialize!(data)
    #
    # Unsafe initialize that doesn't type check. Only called by Document.find and Document.initialize
    #
    @collection = self.class.collection
    @document = data

    self
  end

  #
  # DEFAULT SETTINGS
  #

  set_database :wikimine
end