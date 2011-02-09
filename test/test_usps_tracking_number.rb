require 'test_helper'

class USPSTrackingNumberTest < Test::Unit::TestCase
  context "a USPS tracking number" do
    ["9101 1234 5678 9000 0000 13"].each do |valid_number|
      should "return usps with valid 22 digit number: #{valid_number}" do
        t = TrackingNumber.new("9101 1234 5678 9000 0000 13")
        assert_equal TrackingNumber::USPS91, t.class
        assert_equal :usps, t.carrier
        assert t.valid?
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::USPS91)
      end
    end
    
    # Actual tracking number I got from the USPS that doesn't validate.  UGghhh
    #"7196 9010 7560 0307 7385",
    ["0307 1790 0005 2348 3741"].each do |valid_number|
      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::USPS20)
      end

      should "return usps with valid 20 digit number: #{valid_number}" do
        t = TrackingNumber.new(valid_number)
        assert_equal TrackingNumber::USPS20, t.class
        assert_equal :usps, t.carrier
        assert t.valid?
      end
    end

    ["RB123456785US"].each do |valid_number|
      should "return usps with valid 13 character number #{valid_number}" do
        t = TrackingNumber.new(valid_number)
        assert_equal TrackingNumber::USPS13, t.class
        assert_equal :usps, t.carrier
        assert t.valid?
      end

      should "detect #{valid_number} regardless of spacing" do
        should_detect_number_variants(valid_number, TrackingNumber::USPS13)
      end
    end
  end
end
