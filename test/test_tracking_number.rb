require 'test_helper'

class TrackingNumberTest < Test::Unit::TestCase 
  context "a UPS tracking number" do
    should "return ups as the carrier" do
      assert_equal :ups, TrackingNumber.new("1Z5R89390357567127").carrier
      assert_equal :ups, TrackingNumber.new("1Z879E930346834440").carrier 
      assert_equal :ups, TrackingNumber.new("1Z410E7W0392751591").carrier 
      assert_equal :ups, TrackingNumber.new("1Z8V92A70367203024").carrier 
    end
  end

  context "a FedEx tracking number" do  
    should "return fedex as the carrier if it's a valid fedex express number" do
      t = TrackingNumber.new("986578788855")
      assert_equal :fedex, t.carrier
      assert t.valid?
    
      t = TrackingNumber.new("477179081230")
      assert_equal :fedex, t.carrier 
      assert t.valid?
    end
  
    should "return fedex as the carrier with valid fedex ground (96) number" do
      t = TrackingNumber.new("9611020987654312345672")
      assert_equal :fedex, t.carrier 
      assert t.valid?    
    end

    should "return fedex as the carrier with valid fedex ground (SSCC18) number" do
      t = TrackingNumber.new("000123450000000027")
      assert_equal :fedex, t.carrier 
      assert t.valid?
    end
  end
  
  context "a DHL tracking number" do
    should "return dhl if it's a valid number" do
      t = TrackingNumber.new("73891051146")
      assert_equal :dhl, t.carrier
      assert t.valid?
    end    
  end
  
  context "a USPS tracking number" do  
    should "return usps with if number" do
      t = TrackingNumber.new("9101 1234 5678 9000 0000 13")
      assert_equal :usps, t.carrier
      assert t.valid?
    end
  end
  
  context "a tracking number" do
    should "return unknown when given invalid number" do
      t = TrackingNumber.new("101")
      assert_equal :unknown, t.carrier
      assert !t.valid?
    end
  
    should "upcase and remove spaces from tracking number" do
      t = TrackingNumber.new("abc 123 def")
      assert_equal "ABC123DEF", t.tracking_number
    end
  end
  
  context "tracking number search" do  
    [{"73891051146" => :dhl}, 
     {"1Z8V92A70367203024" => :ups}, 
     {"000123450000000027" => :fedex}, {"9611020987654312345672" => :fedex}, {"477179081230" => :fedex}, 
     {"9101123456789000000013" => :usps}].each do |pair|
      expected_service = pair.to_a.flatten[1]
      tracking = pair.to_a.flatten[0]
          
      should "detect #{expected_service} with number #{tracking} regardless of spacing" do 
        possible_numbers(tracking).each do |spaced_tracking|
          results = TrackingNumber.search("blah blah #{spaced_tracking} blah blah")
          assert_equal 1, results.size, "#{spaced_tracking} did not match #{expected_service}"
          assert_equal expected_service, results.first.carrier
        end
      end
    
      should "not detect #{expected_service} when word word boundaries are not in tact" do  
        possible_numbers(tracking).each do |spaced_tracking|
          bad_number = "x1#{spaced_tracking}1x"          
          results = TrackingNumber.search("blah blah #{bad_number} blah blah")
          assert_equal 0, results.size, "#{bad_number} should not match #{expected_service}"
        end
      end
      
      should "return two tracking numbers when given string with two" do
        s = TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
        assert_equal 2, s.size
      end
    end
  end
end
