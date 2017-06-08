require 'test_helper'

class OnTracTrackingNumberTest < Minitest::Test
  context "a royal mail tracking number" do
    ["FF070621885GB", "TT222209017GB", "TT327219141GB"].each do |valid_number|
      should "return royal_mail for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::RoyalMail, :royal_mail)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::RoyalMail)
      end
    end


    ["TT827210001GB", "TT000000001GB"].each do |invalid_number|
      should "not detect an number for invalid #{invalid_number}" do
        results = TrackingNumber::RoyalMail.search(invalid_number)
        assert_equal 0, results.size
      end
    end
  end
end
