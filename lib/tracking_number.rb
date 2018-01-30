# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html

require 'tracking_number/base'
require 'tracking_number/usps'
require 'tracking_number/fedex'
require 'tracking_number/ups'
require 'tracking_number/dhl'
require 'tracking_number/ontrac'

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end

module TrackingNumber
  TYPES = [UPS, UPSTest, FedExExpress, FedExSmartPost, FedExGround, FedExGround18, FedExGround96, USPS91, USPS20, USPS13, USPSTest, DHLExpress, DHLExpressAir, OnTrac, DHLGlobalMail, RRDonnelleyStandard]

  def self.search(body)
    TYPES.collect { |type| type.search(body) }.flatten
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
