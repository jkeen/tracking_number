require 'test_helper'

class FedExTrackingNumberTest < Minitest::Test
  context "a FedEx tracking number" do
    ["986578788855", "477179081230", "799531274483", "790535312317", "974367662710"].each do |valid_number|
      should "return fedex express for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExExpress, :fedex)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExExpress)
      end
    end

    ["9611020987654312345672"].each do |valid_number|
      should "return fedex 96 for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround96, :fedex)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround96)
      end
    end

    ["0414 4176 0228 964", "5682 8361 0012 000", "5682 8361 0012 734"].each do |valid_number|
      should "return fedex ground for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround, :fedex)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround)
      end
    end

    ["00 0123 4500 0000 0027"].each do |valid_number|
      should "return fedex sscc18 for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround18, :fedex)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround18)
      end
    end

    ['61299998820821171811', '9261292700768711948021'].each do |valid_number|
      should "return fedex smart post for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExSmartPost, :fedex)
      end

      should "fail on check digit changes on #{valid_number}" do
        should_fail_on_check_digit_changes(valid_number)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExSmartPost)
      end
    end
  end
end
