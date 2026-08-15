# Identify if tracking numbers are valid, and which service they belong to

require 'json'
require 'tracking_number/checksum_validations'
require 'tracking_number/loader'
require 'tracking_number/base'
require 'tracking_number/info'
require 'tracking_number/partnership'
require 'tracking_number/unknown'
require 'active_support/all'

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end

TrackingNumber::Loader.load_tracking_number_data

module TrackingNumber
  def self.search(body, match: :carrier)
    matches = TYPES.collect { |type| type.search(body) }.flatten

    # Some tracking numbers (e.g. Fedex Smartpost) are partnerships between two parties, where one party is the shipper (e.g. Fedex)
    # and the other party is the [last mile] carrier (e.g. USPS). We're probably interested in the last mile aspect of
    # the partnership, so by default we'll show those

    # Tracking numbers without a partnership are both the shipper and carrier.

    case match
    when :carrier
      matches.filter(&:carrier?)
    when :shipper
      matches.filter(&:shipper?)
    when :all
      matches
    else
      matches
    end
  end

  def self.detect(tracking_number, match: :carrier)
    all_matches = search(tracking_number, match: match)

    if all_matches.empty?
      Unknown.new(tracking_number)
    else
      all_matches.max_by(&:confidence)
    end
  end

  def self.detect_all(tracking_number)
    matches = []
    (TYPES + [Unknown]).each do |test_klass|
      tn = test_klass.new(tracking_number)
      matches << tn if tn.valid?
    end

    matches
  end

  def self.new(tracking_number)
    detect(tracking_number)
  end

  # Renamed in tracking_number_data 2.0. The old constant still describes the same barcode.
  RENAMED_TYPES = { USPS91: :USPSIMpbC, USPS22: :USPSIMpbN, USPS34v2: :USPSIMpbC }.freeze

  # Removed in tracking_number_data 2.0. An alias would answer is_a? for every IMpb number,
  # which is the claim the data stopped making, so these raise instead.
  WITHDRAWN_TYPES = {
    FedExSmartPost: 'USPSIMpbC',
    DHLECommerce30: 'USPSIMpbC'
  }.freeze

  def self.const_missing(name)
    if (renamed = RENAMED_TYPES[name])
      warn "TrackingNumber::#{name} is now TrackingNumber::#{renamed}"
      return const_get(renamed)
    end

    if (replacement = WITHDRAWN_TYPES[name])
      raise NameError, "TrackingNumber::#{name} no longer exists. These are USPS IMpb barcodes " \
                       "carrying nothing that identifies the shipper, so they now decode as " \
                       "TrackingNumber::#{replacement}."
    end

    super
  end
end
