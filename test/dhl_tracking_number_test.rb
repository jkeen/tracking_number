require 'test_helper'

class DHLTrackingNumberTest < Minitest::Test
  context "a DHL tracking number" do
    ["73891051146"].each do |valid_number|
      should "return dhl for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::DHL, :dhl)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::DHL)
      end
    end
  end
end
