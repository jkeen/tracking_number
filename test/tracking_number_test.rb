require 'test_helper'

class TrackingNumberTest < Minitest::Test
  context "a tracking number" do
    should "return unknown when given invalid number" do
      t = TrackingNumber.new("101")
      assert_equal TrackingNumber::Unknown, t.class
      assert_equal :unknown, t.carrier
      assert_equal :unknown, t.courier_code
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
      assert_equal "UPS", tracking_number.courier_name
    end

    should "report correct service" do
      assert_equal "UPS United States Ground", tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_equal "5R8939", tracking_number.shipper_id
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination_zip
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_type
    end

    should "have valid tracking url" do
      assert tracking_number.tracking_url, "Tracking url should not be blank"
      assert tracking_number.tracking_url.include?(tracking_number.tracking_number), "Should include tracking number in the url"
    end
  end

  context "tracking number additional data for s10" do
    tracking_number = TrackingNumber.new("RB123456785GB")

    should "report correct courier name" do
      assert_equal "Royal Mail Group plc", tracking_number.courier_name
    end

    should "report correct service" do
      assert_equal "Letter Post Registered", tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_nil tracking_number.shipper_id
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination_zip
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_type
    end
  end

  context "tracking number additional data for USPS 20" do
    tracking_number = TrackingNumber.new("0307 1790 0005 2348 3741")

    should "report correct courier name" do
      assert_equal "United States Postal Service", tracking_number.courier_name
    end

    should "report correct service" do
      assert_nil tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_equal "071790000", tracking_number.shipper_id
    end

    should "report correct no destination" do
      assert_nil tracking_number.destination_zip
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_type
    end

    should "have valid tracking url" do
      assert tracking_number.tracking_url, "Tracking url should not be blank"
      assert tracking_number.tracking_url.include?(tracking_number.tracking_number), "Should include tracking number in the url"
    end
  end

  context "tracking number additional data for USPS 34v2" do
    tracking_number = TrackingNumber.new("4201002334249200190132607600833457")

    should "report correct courier name" do
      assert_equal "United States Postal Service", tracking_number.courier_name
    end

    should "report correct service" do
      assert_nil tracking_number.service_type
    end

    should "report correct shipper_id" do
      assert_equal "00190132", tracking_number.shipper_id
    end

    should "report correct no destination" do
      assert_equal "10023", tracking_number.destination_zip
    end

    should "report correct no package info" do
      assert_nil tracking_number.package_type
    end

    should "report no partnership" do
      assert_equal false, tracking_number.partnership?
    end

    should "report no partners" do
      assert_equal nil, tracking_number.partners
    end

    should "report as shipper and carrier" do
      assert_equal true, tracking_number.shipper?
      assert_equal true, tracking_number.carrier?
    end

    should "have valid tracking url" do
      assert tracking_number.tracking_url, "Tracking url should not be blank"
      assert tracking_number.tracking_url.include?(tracking_number.tracking_number), "Should include tracking number in the url"
    end
  end

  context "tracking number partnership data for FedExSmartPost/USPS91" do
    tracking_number = TrackingNumber.new("420 11213 92 6129098349792366623 8")

    should "report correct courier name" do
      assert_equal "United States Postal Service", tracking_number.courier_name
    end

    should "report correct courier code" do
      assert_equal :usps, tracking_number.courier_code
    end

    should "report correct service type" do
      assert_equal "Fedex Smart Post", tracking_number.service_type
    end

    should "report partnership" do
      assert_equal true, tracking_number.partnership?
    end

    should "report not shipper side of the partnership" do
      assert_equal false, tracking_number.shipper?
    end

    should "report carrier side of the partnership" do
      assert_equal true, tracking_number.carrier?
    end

    should "report partner pairing" do
      assert_equal :fedex, tracking_number.partners.shipper.courier_code
    end
  end

  context "searching numbers that have partners" do
    partnership_number = "420 11213 92 6129098349792366623 8"
    single_number = "0307 1790 0005 2348 3741"
  
    search_string = ["number that matches two services", partnership_number, " number that matches only one: ", single_number, "let's see if that does it"].join(' ')

    should "match only carriers by default" do
      matches = TrackingNumber.search(search_string)
      assert_equal 2, matches.size
      assert_equal [true, true], matches.collect { |t| t.carrier? }
    end

    should "match all if specified" do
      matches = TrackingNumber.search(search_string, match: :all)
      assert_equal 3, matches.size
    end

    should "match only shippers if specified" do
      matches = TrackingNumber.search(search_string, match: :shipper)
      assert_equal 2, matches.size
    end
  end
end
