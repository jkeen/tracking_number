require 'test_helper'

class TrackingNumberTest < Test::Unit::TestCase
  should "return ups with valid ups number" do
    assert_equal :ups, TrackingNumber.new("1Z5R89390357567127").carrier
    assert_equal :ups, TrackingNumber.new("1Z879E930346834440").carrier 
    assert_equal :ups, TrackingNumber.new("1Z410E7W0392751591").carrier 
    assert_equal :ups, TrackingNumber.new("1Z8V92A70367203024").carrier 
  end
  
  should "return fedex with valid fedex express number" do
    t = TrackingNumber.new("986578788855")
    assert_equal :fedex, t.carrier
    assert t.valid?
    
    t = TrackingNumber.new("477179081230")
    assert_equal :fedex, t.carrier 
    assert t.valid?
  end
  
  should "return fedex with valid fedex ground (96) number" do
    t = TrackingNumber.new("9611020987654312345672")
    assert_equal :fedex, t.carrier 
    assert t.valid?    
  end

  should "return fedex with valid fedex ground (SSCC18) number" do
    t = TrackingNumber.new("000123450000000027")
    assert_equal :fedex, t.carrier 
    assert t.valid?
  end
  
  should "return dhl with valid dhl number" do
    t = TrackingNumber.new("73891051146")
    assert_equal :dhl, t.carrier
    assert t.valid?
  end
  
  should "return usps with valid usps number" do
    t = TrackingNumber.new("9101 1234 5678 9000 0000 13")
    assert_equal :usps, t.carrier
    assert t.valid?
  end
  
  should "return unknown when given invalid number" do
    t = TrackingNumber.new("101")
    assert_equal :unknown, t.carrier
    assert !t.valid?
  end
  
  should "upcase and remove spaces from tracking number" do
    t = TrackingNumber.new("abc 123 def")
    assert_equal "ABC123DEF", t.tracking_number
  end
  
  should "return two tracking numbers when given test search string" do
    s = TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    
    assert_equal 2, s.size
  end
end
