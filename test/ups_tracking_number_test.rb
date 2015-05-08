require 'test_helper'

class UPSTrackingNumberTest < Minitest::Test
  context "a UPS tracking number" do
    ["1Z5R89390357567127", "1Z879E930346834440", "1Z410E7W0392751591", "1Z8V92A70367203024"].each do |valid_number|
      should "return ups with valid number #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::UPS, :ups)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::UPS)
      end
    end
  end
end
