# Identify if tracking numbers are valid, and which service they belong to

require 'json'
require 'tracking_number/checksum_validations'
require 'tracking_number/loader'
require 'tracking_number/base'
require 'tracking_number/info'
require 'tracking_number/unknown'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end

TrackingNumber::Loader.load_tracking_number_data

module TrackingNumber
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

  def self.detect_all(tracking_number)
    matches = []
    for test_klass in (TYPES+[Unknown])
      tn = test_klass.new(tracking_number)
      matches << tn if tn.valid?
    end
    return matches
  end

  def self.new(tracking_number)
    self.detect(tracking_number)
  end
end
