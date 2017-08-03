require 'test_helper'

class TrackingNumberDataTest < Minitest::Test
  Dir.glob(File.join(File.dirname(__FILE__), "../lib/data/couriers/*.json")).each do |file|
    courier_info = JSON.parse(File.read(file)).deep_symbolize_keys!
    courier_name = courier_info[:name]

    context "#{courier_info[:name]}" do
      courier_code = courier_info[:courier_code].to_sym

      courier_info[:tracking_numbers].each do |tracking_info|
        klass_name = tracking_info[:name].gsub(/[^0-9A-Za-z]/, '')

        context "valid numbers for #{tracking_info[:name]}" do
          tracking_info[:test_numbers][:valid].each do |valid_number|
            should "#{valid_number} should report as valid :#{courier_code}" do
              should_be_valid_number(valid_number, "TrackingNumber::#{klass_name}".constantize, courier_code)
            end

            should "fail on check digit changes on #{valid_number}" do
              should_fail_on_check_digit_changes(valid_number)
            end

            should "detect #{valid_number} regardless of spacing" do
              should_detect_number_variants(valid_number, "TrackingNumber::#{klass_name}".constantize)
            end
          end
        end

        context "invalid numbers for #{tracking_info[:name]}" do
          tracking_info[:test_numbers][:invalid].each do |invalid_number|
            should "#{invalid_number} should report as invalid" do
              should_be_invalid_number(invalid_number, "TrackingNumber::#{klass_name}".constantize, courier_code)
            end
          end
        end

      end
    end
  end
end
