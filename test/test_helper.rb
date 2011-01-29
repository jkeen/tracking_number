require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tracking_number'

class Test::Unit::TestCase
  def possible_numbers(tracking)
    possible_numbers = []
    possible_numbers << tracking
    possible_numbers << tracking.chars.to_a.join(" ")
    possible_numbers << tracking.chars.to_a.join("  ")
    possible_numbers << tracking.slice(0, (tracking.length / 2)) + "  " + tracking.slice((tracking.length / 2), tracking.length)
    
    possible_numbers
  end
  
end
