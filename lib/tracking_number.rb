# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html

require 'base'
require 'usps'
require 'fedex'
require 'ups'
require 'dhl'

class TrackingNumber
  TYPES = [UPS, FedExExpress, FedExGround, FedExGround18, FedExGround96, USPS91, USPS20, USPS13, DHL]

  def self.search(body)
    TYPES.collect { |type| type.search(body) }.flatten
  end

  def self.detect(tracking_number)
    detected = TYPES.collect do |test|
      t = test.new(tracking_number)
      t if t.valid?
    end
    found = detected.compact.first

    return found if found
    return Unknown.new(tracking_number)
  end

  def self.new(tracking_number)
    self.detect(tracking_number)
  end
end
