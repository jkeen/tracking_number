require 'test_helper'

class TrackingNumberDataTest < Minitest::Test
  Dir.glob(File.join(File.dirname(__FILE__), "../lib/data/couriers/*.json")).each do |file|
    courier_info = JSON.parse(File.read(file)).deep_symbolize_keys!
    courier_name = courier_info[:name]

      courier_code = courier_info[:courier_code].to_sym

      courier_info[:tracking_numbers].each do |tracking_info|
        klass_name = tracking_info[:name].gsub(/[^0-9A-Za-z]/, '')
        klass = "TrackingNumber::#{klass_name}".constantize
        context "[#{tracking_info[:name]}]" do
          tracking_info[:test_numbers][:valid].each do |valid_number|

            should "validate #{valid_number} with #{klass_name}" do
              t = klass.new(valid_number)
              assert_equal courier_code, t.carrier
              assert t.valid?, "should be valid"
            end

            should "detect #{valid_number} as #{klass_name}" do
              t = TrackingNumber.new(valid_number)
              assert_equal klass, t.class
            end

            if tracking_info[:validation][:checksum]
              # only run this test if number format has checksum
              should "fail on check digit changes with #{valid_number}" do
                should_fail_on_check_digit_changes(valid_number)
              end
            end

            should "detect #{valid_number} regardless of spacing" do
              should_detect_number_variants(valid_number, "TrackingNumber::#{klass_name}".constantize)
            end
          end

          tracking_info[:test_numbers][:invalid].each do |invalid_number|
            should "not validate #{invalid_number} with #{klass_name}" do
              t = klass.new(invalid_number)
              assert !t.valid?, "should not be valid"
            end
          end
        end
      end
  end
end
