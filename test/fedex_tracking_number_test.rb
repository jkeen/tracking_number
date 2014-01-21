require 'test_helper'

class FedExTrackingNumberTest < Test::Unit::TestCase
  context "a FedEx tracking number" do
    ["986578788855", "477179081230", "799531274483", "790535312317"].each do |valid_number|
      should "return fedex express for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExExpress, :fedex)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExExpress)
      end
    end

    ["9611020987654312345672"].each do |valid_number|
      should "return fedex 96 for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround96, :fedex)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround96)
      end
    end

    ["0414 4176 0228 964", "5682 8361 0012 000", "5682 8361 0012 734"].each do |valid_number|
      should "return fedex ground for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround, :fedex)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround)
      end
    end

    ["00 0123 4500 0000 0027"].each do |valid_number|
      should "return fedex sscc18 for #{valid_number}" do
        should_be_valid_number(valid_number, TrackingNumber::FedExGround18, :fedex)
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::FedExGround18)
      end
    end

    ["986578788855", "477179081230", "799531274483", "790535312317"].each do |valid_number|
      should "return fedex tracking ur for #{valid_number}" do
        tn = TrackingNumber.detect(valid_number)
        assert tn.kind_of?(TrackingNumber::FedEx)
        assert_equal tn.uri.to_s, "http://www.fedex.com/Tracking?action=track&tracknumbers=#{valid_number}"
      end
    end

  end
end