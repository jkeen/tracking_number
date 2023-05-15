require 'simplecov'
SimpleCov.start
require 'rubygems'
require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda'
require 'active_model'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tracking_number'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

class Minitest::Test
  def possible_numbers(tracking)
    tracking = tracking.to_s
    possible_numbers = []
    possible_numbers << tracking
    possible_numbers << tracking.to_s.gsub(" ", "")
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
      assert_equal 1, results.size, "could not find #{type} #{valid_number} in #{string} using search regex: #{type::SEARCH_PATTERN}"
    end
  end

  def should_be_valid_number(valid_number, type, carrier)
    t = TrackingNumber.new(valid_number)
    assert_equal type, t.class
    assert_equal carrier, t.carrier
    assert t.valid?
  end

  def should_be_invalid_number(invalid_number, type, carrier)
    t = TrackingNumber.new(invalid_number)
    assert !t.valid?
  end

  def should_fail_on_check_digit_changes(valid_number)
    digits = valid_number.gsub(/\s/, "").chars.to_a
    last = digits.pop.to_i
    digits << (last  < 2 ? last + 3 : last - 3).to_s
    invalid_number = digits.join
    t = TrackingNumber.new(invalid_number)
    assert !t.valid?, "#{invalid_number} reported as a valid #{t.class}, and it shouldn't be"
  end
end
