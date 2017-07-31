# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html
require 'json'
require 'tracking_number/base'
require 'checksum_validations'
require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require "awesome_print"

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end

def has_test_numbers?(tracking)
  return tracking[:test_numbers] && tracking[:test_numbers][:valid]
end

def test_numbers_return_required_groups?(tracking, regex)
  test_number = tracking[:test_numbers][:valid][0]
  matches = test_number.match(regex)

  return (matches["SerialNumber"] && matches["CheckDigit"])
end

tracking_number_types = []
named_group_info = {}

Dir.glob(File.join(File.dirname(__FILE__), "data/couriers/*.json")).each do |file|
  courier_info = JSON.parse(File.read(file)).deep_symbolize_keys!

  courier_name = courier_info[:name]
  courier_code = courier_info[:courier_code]
  courier_info[:tracking_numbers].each do |tracking_info|
    klass = Class.new(TrackingNumber::Base)

    pattern = tracking_info[:regex]
    pattern = tracking_info[:regex].join if tracking_info[:regex].is_a?(Array)

    verify_pattern = "^(#{pattern})$"
    search_pattern = "\b*(#{pattern})\b*"

    klass.const_set("COURIER_CODE", courier_code)
    klass.const_set("SEARCH_PATTERN", Regexp.new("\b*(#{pattern})\b*"))
    klass.const_set("VERIFY_PATTERN", Regexp.new("^(#{pattern})$"))

    klass.const_set("VALIDATION", tracking_info[:validation])
    klass.const_set("ADDITIONAL", tracking_info[:additional])

    throw 'missing test numbers' unless has_test_numbers?(tracking_info)
    throw 'missing regex match groups' unless test_numbers_return_required_groups?(tracking_info, Regexp.new(verify_pattern))

    test_number = tracking_info[:test_numbers][:valid][0]

    test_number.match(klass::VERIFY_PATTERN).names.each do |name|
      named_group_info[name] ||= 0
      named_group_info[name] += 1
    end

    module_name = courier_name.gsub(/[^0-9A-Za-z]/, '')
    klass_name = tracking_info[:name].gsub(/[^0-9A-Za-z]/, '')

    const = TrackingNumber.const_set(klass_name, klass)
    tracking_number_types.push(const)
  end
end

TrackingNumber.const_set("TYPES", tracking_number_types)

module TrackingNumber
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
