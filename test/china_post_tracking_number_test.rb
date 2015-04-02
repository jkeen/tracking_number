require 'test_helper'

class ChinaPostTrackingNumberTest < Test::Unit::TestCase
  context "a China Post tracking number" do
    ["LN093524229CN", "RR123456789CN"].each do |valid_number|
      should "return china_post with valid number #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::ChinaPost, :china_post)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::ChinaPost)
      end
    end
  end
end