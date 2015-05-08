require 'test_helper'

class DHLTrackingNumberTest < Minitest::Test
  context "DHLExpressAir tracking number" do
    ["73891051146"].each do |valid_number|
      should "return dhl for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::DHLExpressAir, :dhl)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::DHLExpressAir)
      end
    end
  end

  context "DHLExpress tracking numbers" do
    ["3318810025", "8487135506", "3318810036", "3318810014"].each do |valid_number|
      should "return dhl for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::DHLExpress, :dhl)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::DHLExpress)
      end
    end
  end
end
