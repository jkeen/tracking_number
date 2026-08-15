require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class RenamedTypesTest < Minitest::Test
  NUMBER = '420112139261290983497923666238'.freeze

  should "resolve a renamed constant to the definition that replaced it" do
    assert_equal TrackingNumber::USPSIMpbC, silenced { TrackingNumber::USPS91 }
    assert_equal TrackingNumber::USPSIMpbN, silenced { TrackingNumber::USPS22 }
    assert_equal TrackingNumber::USPSIMpbC, silenced { TrackingNumber::USPS34v2 }
  end

  should "keep is_a? answering for a renamed constant" do
    assert TrackingNumber.new(NUMBER).is_a?(silenced { TrackingNumber::USPS91 })
  end

  should "warn once a renamed constant is reached for" do
    _, err = capture_io { TrackingNumber::USPS91 }

    assert_match(/USPS91 is now TrackingNumber::USPSIMpbC/, err)
  end

  # An alias would answer is_a? for every IMpb number, including labels these carriers never touched
  should "refuse a withdrawn constant and name its replacement" do
    error = assert_raises(NameError) { TrackingNumber::FedExSmartPost }
    assert_match(/no longer exists/, error.message)
    assert_match(/USPSIMpbC/, error.message)

    assert_raises(NameError) { TrackingNumber::DHLECommerce30 }
  end

  should "leave an unrelated missing constant alone" do
    error = assert_raises(NameError) { TrackingNumber::NotADefinition }

    assert_match(/uninitialized constant/, error.message)
  end

  private

  def silenced
    resolved = nil
    capture_io { resolved = yield }
    resolved
  end
end
