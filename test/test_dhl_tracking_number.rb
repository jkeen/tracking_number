require 'test_helper'

class DHLTrackingNumberTest < Test::Unit::TestCase
  context "a DHL tracking number" do
    ["73891051146"].each do |valid_number|
      should "return dhl for #{valid_number}" do
        t = TrackingNumber.new(valid_number)
        assert_equal :dhl, t.carrier
        assert t.valid?
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::DHL)
      end
    end
  end
end