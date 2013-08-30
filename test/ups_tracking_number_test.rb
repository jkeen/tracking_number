require 'test_helper'

class UPSTrackingNumberTest < Test::Unit::TestCase
  context "a UPS tracking number" do
    ["1Z5R89390357567127", "1Z879E930346834440", "1Z410E7W0392751591", "1Z8V92A70367203024"].each do |valid_number|
      should "return ups with valid number #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::UPS, :ups)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::UPS)
      end
    end

    ["1Z5R89390357567127", "1Z879E930346834440", "1Z410E7W0392751591", "1Z8V92A70367203024"].each do |valid_number|
      should "return ups tracking ur for #{valid_number}" do
        tn = TrackingNumber.detect(valid_number)
        assert tn.kind_of?(TrackingNumber::UPS)
        assert_equal tn.uri.to_s, "http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{valid_number}"
      end
    end
  end
end