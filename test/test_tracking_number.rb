require 'test_helper'

class TrackingNumberTest < Test::Unit::TestCase
  context "a tracking number" do
    should "return unknown when given invalid number" do
      t = TrackingNumber.new("101")
      assert_equal TrackingNumber::Unknown, t.class
      assert_equal :unknown, t.carrier
      assert !t.valid?
    end

    should "upcase and remove spaces from tracking number" do
      t = TrackingNumber.new("abc 123 def")
      assert_equal "ABC123DEF", t.tracking_number
    end
  end

  context "tracking number search" do
    should "return two tracking numbers when given string with two" do
      s = TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
      assert_equal 2, s.size
    end
  end
end
