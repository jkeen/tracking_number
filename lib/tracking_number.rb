# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html
require 'json'
require 'tracking_number/base'
require 'tracking_number/usps'
require 'tracking_number/fedex'
require 'tracking_number/ups'
require 'tracking_number/dhl'
require 'tracking_number/ontrac'
require 'checksum_validations';
# require 'tracking_number/royal_mail'

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end


File.open(File.join(File.dirname(__FILE__), "data.json")) do |file|
  contents = JSON.parse(File.read(file))
  contents["carriers"].each do |company|
    company["tracking_numbers"].each do |tracking|
      klass = Class.new(TrackingNumber::Base) do
      end

      klass.instance_eval do
        define_method "carrier" do
          company["carrier_code"].to_sym
        end

        define_method "valid_checksum?" do
          settings    = tracking["check_digit"]
          start_index = settings["start_index"].to_i
          end_index   = settings["end_index"].to_i
          check_index = settings["check_index"].to_i
          weighting   = settings["weighting"]

          sequence    = self.tracking_number.slice(start_index, end_index)
          prefix      = settings["required_prefix"]

          if (prefix && !sequence.start_with?(prefix.to_s))
            sequence = "#{prefix}#{sequence}"
          end

          check_digit = self.tracking_number.chars[check_index].to_i

          algorithm   = settings["type"]

          ChecksumValidations.send("validates_#{algorithm}?", sequence || "", check_digit || nil, {:weighting => weighting})
        end
      end

      verify_pattern = "^(#{tracking["pattern"].join})$"

      search_pattern = tracking["pattern"].collect { |p| "#{p}\\s*"}.join
      search_pattern = "\\b#{search_pattern}\\b"

      klass.const_set("SEARCH_PATTERN", Regexp.new(search_pattern))
      klass.const_set("VERIFY_PATTERN", Regexp.new(verify_pattern))

      TrackingNumber.const_set(tracking["type_name"], klass)
    end
  end
end

module TrackingNumber
  TYPES = [
    UPS, UPSTest,
    FedExExpress, FedExGround, FedExSmartPost, FedExGround18, FedExGround96,
    USPS91, USPS20, USPS13, USPSTest,
    DHLExpress, DHLExpressAir,
    OnTrac,
    USPS13,
    RoyalMail]

  def self.search(body)
    TYPES.collect { |type| type.search(body) }.flatten
  end

  def self.scan(body)
    TYPES.collect { |type|
      if (!type.scan(body).empty?)
        type
      end
    }.compact
  end

  def self.detect(tracking_number)
    tn = nil
    for test_klass in (TYPES+[Unknown])
      tn = test_klass.new(tracking_number)
      break if tn.valid?
    end
    return tn
  end

  def self.new(tracking_number)
    self.detect(tracking_number)
  end
end
