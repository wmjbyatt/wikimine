require 'em-irc'

class IrcScraper
  #
  # Class to scrape irc.wikimedia.org channels for updates
  #

  attr_reader :client

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
        reference.record_message message unless message.blank?
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
      WikipediaChangeLog.new(parsed_message).save
      puts "Created a record"
    else
      puts "Did not create record"
    end
  end

  protected

  def parse_message message
    match_data = message.match(/#{ARTICLE}.*#{DIFF}\s*#{AUTHOR}\s*#{CHANGE_COUNT}\s*#{SECTION}\s+#{COMMIT_MSG}/)
    #
    # This is a bitch of a regex. We really ought to use a parser for this, but I'm not excited about bringing an entire
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