require 'test_helper'

def load_courier_data(name = :all)
  if name == :all
    Dir.glob(File.join(File.dirname(__FILE__), "../lib/data/couriers/*.json")).collect do |file|
      JSON.parse(File.read(file)).deep_symbolize_keys!
    end
  else
    return JSON.parse(File.join(File.dirname(__FILE__), "../lib/data/couriers/#{name}.json"))
  end
end

class TrackingNumberMetaTest < Minitest::Test
  load_courier_data(:all).each do |courier_info|
    courier_name = courier_info[:name]
    courier_code = courier_info[:courier_code].to_sym

    courier_info[:tracking_numbers].each do |tracking_info|
      klass_name = tracking_info[:name].gsub(/[^0-9A-Za-z]/, '')
      klass = "TrackingNumber::#{klass_name}".constantize

      describe "[#{tracking_info[:name]}]" do
        tracking_info[:test_numbers][:valid].each do |valid_number|
          should "detect #{valid_number} as #{klass_name}" do
            #TODO fix this multiple matching thing
            matches = TrackingNumber.search(valid_number)
            assert matches.collect(&:class).include?(klass)
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

          context "number test" do
            tracking_number = klass.new(valid_number)

            should "validate #{valid_number} with #{klass_name}" do
              assert_equal courier_code, tracking_number.carrier
              assert tracking_number.valid?, "should be valid"
            end

            should "return correct courier code on #{valid_number} when calling #courier_code" do
              tracking_number = klass.new(valid_number)
              assert_equal courier_info[:courier_code].to_sym, tracking_number.courier_code
              assert_equal courier_info[:courier_code].to_sym,tracking_number.courier_code
            end

            should "return correct courier name on #{valid_number} when calling #courier_name" do
              if (tracking_number.matching_additional["Courier"])
                assert_equal tracking_number.matching_additional["Courier"][:courier], tracking_number.courier_name
              else
                assert_equal courier_name, tracking_number.courier_name
              end
            end

            should "not throw an error when calling #service_type on #{valid_number}" do
              service_type = tracking_number.service_type
              assert service_type.is_a?(String) || service_type.nil?
            end

            should "not throw an error when calling #destination on #{valid_number}" do
              assert tracking_number.destination_zip.is_a?(String) || tracking_number.destination_zip.nil?
            end

            should "not throw an error when calling #shipper on #{valid_number}" do
              t = klass.new(valid_number)
              assert tracking_number.shipper_id.is_a?(String) || tracking_number.shipper_id.nil?
            end

            should "not throw an error when calling #package_type on #{valid_number}" do
              t = klass.new(valid_number)
              assert tracking_number.package_type.is_a?(String) || tracking_number.package_type.nil?
            end

            should "not throw an error when calling #decode on #{valid_number}" do
              t = klass.new(valid_number)
              decode = tracking_number.decode
              assert decode.is_a?(Hash)
            end

          end
        end

        tracking_info[:test_numbers][:invalid].each do |invalid_number|
          should "not validate #{invalid_number} with #{klass_name}" do
            t = klass.new(invalid_number)
            assert !t.valid?, "should not be valid"
          end

          should "not throw an error when calling #service_type on invalid number #{invalid_number}" do
            t = klass.new(invalid_number)
            service_type = t.service_type
            assert service_type.is_a?(String) || service_type.nil?
          end

          should "not throw an error when calling #destination_zip on invalid number #{invalid_number}" do
            t = klass.new(invalid_number)
            destination = t.destination_zip
            assert  destination.is_a?(String) || destination.nil?
          end

          should "not throw an error when calling #shipper_id on invalid number #{invalid_number}" do
            t = klass.new(invalid_number)
            shipper = t.shipper_id
            assert shipper.is_a?(String) || shipper.nil?
          end

          should "not throw an error when calling #package_type on invalid number #{invalid_number}" do
            t = klass.new(invalid_number)
            assert t.package_type.is_a?(String) || t.package_type.nil?
          end

          should "not throw an error when calling #decode on invalid number #{invalid_number}" do
            t = klass.new(invalid_number)
            decode = t.decode
            assert decode.is_a?(Hash)
          end
        end
      end
    end
  end

  test_numbers = []
  load_courier_data(:all).each do |courier_info|
    courier_info[:tracking_numbers].each do |tracking_info|
      test_numbers << tracking_info[:test_numbers][:valid]
    end
  end

  test_numbers.flatten!

  test_numbers.each do |number|
    matches = TrackingNumber.detect_all(number)
    if (matches.size > 1)
      puts "WARNING: #{number.gsub(/\s/, '')} matched multiple types => #{matches.collect { |m| m.class.to_s.split("::").last}}"
    end
  end
end
