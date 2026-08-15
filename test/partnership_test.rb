require File.expand_path(File.dirname(__FILE__) + '/test_helper')

# No shipped definition declares partners currently at the tracking number data 2.0 release, 
# but the concept is still supported in the data spec, and should be tested, so we're faking it here

class PartnershipTest < Minitest::Test
  NUMBER = 'ZZ1234567890'.freeze

  def setup
    @shipper = build_class('test_shipper', partner_id: 'test_carrier', partner_type: 'carrier')
    @carrier = build_class('test_carrier', partner_id: 'test_shipper', partner_type: 'shipper')

    TrackingNumber::TYPES.push(@shipper, @carrier)
  end

  def teardown
    TrackingNumber::TYPES.delete(@shipper)
    TrackingNumber::TYPES.delete(@carrier)
  end

  should "report a partnership from both sides" do
    assert @shipper.new(NUMBER).partnership?
    assert @carrier.new(NUMBER).partnership?
  end

  should "pair each side with the other" do
    partners = @carrier.new(NUMBER).partners

    assert_instance_of @shipper, partners.shipper
    assert_instance_of @carrier, partners.carrier
  end

  should "report which side of the partnership each is" do
    assert @shipper.new(NUMBER).shipper?
    assert !@shipper.new(NUMBER).carrier?

    assert @carrier.new(NUMBER).carrier?
    assert !@carrier.new(NUMBER).shipper?
  end

  should "only match the carrier side when searching by default" do
    matches = TrackingNumber.search("shipped as #{NUMBER} today")

    assert_equal [@carrier], matches.collect(&:class)
  end

  should "match both sides when searching for all" do
    matches = TrackingNumber.search("shipped as #{NUMBER} today", match: :all)

    assert_equal [@shipper, @carrier], matches.collect(&:class)
  end

  private

  def build_class(id, partner_id:, partner_type:)
    pattern = 'Z\s*Z\s*(?<SerialNumber>([0-9]\s*){10})'

    klass = Class.new(TrackingNumber::Base)
    klass.const_set('ID', id)
    klass.const_set('COURIER_CODE', id.to_sym)
    klass.const_set('COURIER_INFO', name: id, courier_code: id.to_sym)
    klass.const_set('SEARCH_PATTERN', Regexp.new("\\b#{pattern}\\b"))
    klass.const_set('VERIFY_PATTERN', Regexp.new("^#{pattern}$"))
    klass.const_set('VALIDATION', {})
    klass.const_set('ADDITIONAL', nil)
    klass.const_set('TRACKING_URL', nil)
    klass.const_set('PARTNERS', [{ partner_id: partner_id, partner_type: partner_type }])

    klass
  end
end
