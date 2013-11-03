require_relative 'helper'

class TestIrcScraper < Minitest::Test
  def setup
    @scraper = IrcScraper.new
  end

  def test_that_scraper_is_real
    assert @scraper.is_a?(IrcScraper)
  end

  def test_that_scraper_has_methods
    assert @scraper.respond_to?(:record_message)
  end

  def test_that_record_message_works
    assert_equal "foo", @scraper.record_message("foo")
  end
end