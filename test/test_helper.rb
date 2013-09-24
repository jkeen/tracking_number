require 'rubygems'
# if not defined?(Bundler)
#   require 'bundler'
#   begin
#     Bundler.setup(:default, :development)
#   rescue Bundler::BundlerError => e
#     $stderr.puts e.message
#     $stderr.puts "Run `bundle install` to install missing gems"
#     exit e.status_code
#   end
# end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tracking_number'

class Test::Unit::TestCase
  def possible_numbers(tracking)
    tracking = tracking.to_s
    possible_numbers = []
    possible_numbers << tracking
    possible_numbers << tracking.to_s.gsub(" ", "")
    possible_numbers << tracking.chars.to_a.join(" ")
    possible_numbers << tracking.chars.to_a.join("  ")
    possible_numbers << tracking.slice(0, (tracking.length / 2)) + "  " + tracking.slice((tracking.length / 2), tracking.length)

    possible_numbers.flatten.uniq
  end

  def possible_strings(tracking)
    possible_numbers(tracking).flatten.collect { |t| search_string(t) }
  end

  def search_string(number)
    %Q{Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor #{number} ut labore et dolore magna aliqua.}
  end

  def should_detect_number_variants(valid_number, type)
    possible_strings(valid_number).each do |string|
      results = type.search(string)
      assert_equal 1, results.size, "could not find #{type} #{valid_number} in #{string}"
    end
  end

  def should_be_valid_number(valid_number, type, carrier)
    t = TrackingNumber.new(valid_number)
    assert_equal type, t.class
    assert_equal carrier, t.carrier
    assert t.valid?
  end
end
