require 'em-irc'

class IrcScraper
  #
  # Class to scrape irc.wikimedia.org channels for updates
  #

  attr_reader :client
  attr_reader :publishers


  #
  # CONSTANTS
  #

  # Regex Chunks
  ARTICLE = /\[\[(.*)\]\]/
  DIFF = /(http.*diff=(\d+)&oldid=(\d+))/
  AUTHOR = /\*\s(.*)\s\*/
  CHANGE_COUNT = /\(([-+]\d+)\)/
  SECTION = /(?:\/\*\s(.+)\s\*\/)?/
  COMMIT_MSG = /(.*)?/

  #
  # Instance methods
  #

  def initialize(opts = {:autostart=> false, :channels => ['#en.wikipedia']})
    reference = self

    # Create a collection of publish channels. This way if there are multiple IRC channels sub'd, we can publish to
    # specific publish channels
    @publishers = Hash.new
    opts[:channels].each do |channel|
      @publishers[channel] = RedisPublisher.new channel
    end

    puts @publishers.inspect

    # Build and set up IRC client
    @client = EventMachine::IRC::Client.new do
      host 'irc.wikimedia.org'
      port '6667'

      on :connect do
        nick 'wikimine'
      end

      on :nick do
        opts[:channels].each do |channel|
          join channel
        end
      end

      on :message do |source, target, message|
        # Record a message and, if succesful, publish the object _id
        if record = reference.record_message(message)
          reference.publishers[target].publish record._id
        end
      end
    end
  end

  def start!
    @client.run!
  end

  def stop!
    @client.quit
  end

  def record_message message
    message.gsub! /\cC\d{1,2}(?:,\d{1,2})?|[\cC\cB\cI\cU\cR\cO]/, '' # Stripping out IRC color-control sequences

    if parsed_message = self.parse_message(message)
      record = WikipediaChangeLog.new(parsed_message)
      record.save

      return record
    else
      return false
    end
  end

  protected

  def parse_message message
    match_data = message.match(/#{ARTICLE}.*#{DIFF}\s*#{AUTHOR}\s*#{CHANGE_COUNT}\s*#{SECTION}\s+#{COMMIT_MSG}/)
    #
    # This is a bitch of a regex. I really ought to use a parser for this, but I'm not excited about bringing an entire
    # parser or tokenizer gem into the picture for the sake of a single gnarly match. So instead I cut the regex into
    # chunks that I've defined as constants above.
    #

    {
      :article => match_data[1],
      :diff_link => match_data[2],
      :diff => match_data[3],
      :old_id => match_data[4],
      :author => match_data[5],
      :change_count => match_data[6],
      :section => match_data[7],
      :message => match_data[8]

    }
  rescue NoMethodError # Executed if match_data[] fails because match_data is nil
    return nil
  end


end