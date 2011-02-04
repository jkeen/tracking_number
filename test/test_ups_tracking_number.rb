require 'test_helper'

class UPSTrackingNumberTest < Test::Unit::TestCase
  context "a UPS tracking number" do
    ["1Z5R89390357567127", "1Z879E930346834440", "1Z410E7W0392751591", "1Z8V92A70367203024"].each do |valid_number|
      should "return ups with valid number #{valid_number}" do
        t =  TrackingNumber.new(valid_number)
        assert_equal TrackingNumber::UPS, t.class
        assert_equal :ups, t.carrier
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::UPS)
      end
    end
  end
end