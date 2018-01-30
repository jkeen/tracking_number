require 'test_helper'

class TrackingNumberTest < Minitest::Test
  context "a tracking number" do
    should "return unknown when given invalid number" do
      t = TrackingNumber.new("101")
      assert_equal TrackingNumber::Unknown, t.class
      assert_equal :unknown, t.carrier
      assert_equal :unknown, t.courier.code
      assert_equal "Unknown", t.courier.name
      assert_equal "Unknown", t.courier_name

      assert !t.valid?
    end

    should "upcase and remove spaces from tracking number" do
      t = TrackingNumber.new("abc 123 def")
      assert_equal "ABC123DEF", t.tracking_number
    end

    should "remove leading and trailing whitespace from tracking number" do
      t = TrackingNumber.new("  ABC123 \n")
      assert_equal "ABC123", t.tracking_number
    end
  end

  context "tracking number search" do
    should "return two tracking numbers when given string with two" do
      s = TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
      assert_equal 2, s.size
    end

    should "return two ups tracking numbers when given string with two ups tracking numbers" do
      s = TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z5R89390357567127 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 1Z879E930346834440 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
      assert_equal 2, s.size
      assert_equal [TrackingNumber::UPS, TrackingNumber::UPS], s.collect { |t| t.class }
    end

    should "return tracking numbers without trailing whitespace" do
      s = TrackingNumber.search("hello 1Z879E930346834440\nbye")
      assert_equal 1, s.size
      assert_equal "1Z879E930346834440", s.first.tracking_number
    end
  end

  context "tracking number additional data for ups" do
    tracking_number = TrackingNumber.new("1Z5R89390357567127")

    should "report correct courier name" do
      assert_equal "UPS", tracking_number.courier.name
    end

    should "report correct service" do
      assert_equal "UPS United States Ground", tracking_number.service_type.name
    end

    should "report correct shipper_id" do
      assert_equal "5R8939", tracking_number.shipper.shipper_id
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_info
    end
  end

  context "tracking number additional data for s10" do
    tracking_number = TrackingNumber.new("RB123456785GB")

    should "report correct courier name" do
      assert_equal "Royal Mail Group plc", tracking_number.courier.name
    end

    should "report correct service" do
      assert_equal "Letter Post Registered", tracking_number.service_type.name
    end

    should "report correct shipper_id" do
      assert_nil tracking_number.shipper
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_info
    end
  end

  context "tracking number additional data for USPS 20" do
    tracking_number = TrackingNumber.new("0307 1790 0005 2348 3741")

    should "report correct courier name" do
      assert_equal "United States Postal Service", tracking_number.courier.name
    end

    should "report correct service" do
      assert_nil tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_nil tracking_number.shipper
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_info
    end
  end

  context "tracking number additional data for USPS 34v2" do
    tracking_number = TrackingNumber.new("4201002334249200190132607600833457")

    should "report correct courier name" do
      assert_equal "United States Postal Service", tracking_number.courier.name
    end

    should "report correct service" do
      assert_nil tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_equal "00190132", tracking_number.shipper.shipper_id
    end

    should "report correct no destination" do
      assert_equal "10023", tracking_number.destination.zipcode
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_info
    end
  end
end
