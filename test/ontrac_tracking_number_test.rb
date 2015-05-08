require 'test_helper'

class OnTracTrackingNumberTest < Minitest::Test
  context "an OnTrac tracking number" do
    ["C11031500001879", "C10999911320231"].each do |valid_number|
      should "return ontrac for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::OnTrac, :ontrac)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::OnTrac)
      end
    end

    should "not detect an invalid number" do
      results = TrackingNumber::OnTrac.search("C10999911320230")
      assert_equal 0, results.size
    end
  end
end
