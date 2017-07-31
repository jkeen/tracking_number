# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html
require 'json'
require 'tracking_number/base'
require 'checksum_validations'
require 'active_support'
require 'active_support/core_ext/string'

if defined?(ActiveModel::EachValidator)
  require 'tracking_number/active_model_validator'
end



def has_test_numbers?(tracking)
  return tracking["test_numbers"] && tracking["test_numbers"]["valid"]
end

def test_numbers_return_required_groups?(tracking, regex)
  test_number = tracking["test_numbers"]["valid"][0]
  matches = test_number.match(regex)

  return (matches["SerialNumber"] && matches["CheckDigit"])
end

def define_tracking_number_class(tracking_info)
  klass = Class.new(TrackingNumber::Base)


  pattern = tracking_info["regex"]
  pattern = tracking_info["regex"].join if tracking_info["regex"].is_a?(Array)

  verify_pattern = "^(#{pattern})$"
  search_pattern = "\b*(#{pattern})\b*"

  klass.const_set("SEARCH_PATTERN", Regexp.new(search_pattern))
  klass.const_set("VERIFY_PATTERN", Regexp.new(verify_pattern))

  throw 'missing test numbers' unless has_test_numbers?(tracking_info)
  throw 'missing regex match groups' unless test_numbers_return_required_groups?(tracking_info, Regexp.new(verify_pattern))

  klass.instance_eval do
    define_method "serial_number" do
      format_info   = tracking_info["validation"]["serial_number_format"]
      raw_serial    = self.matches["SerialNumber"]

      if format_info
        if to_prepend = format_info["prepend_if_missing"]
          "#{to_prepend}#{raw_serial}" if raw_serial && !raw_serial.start_with?(to_prepend)
        end
      else
        raw_serial
      end
    end

    define_method "check_digit" do
      self.matches["CheckDigit"]
    end

    define_method "valid_checksum?" do
      return false unless self.valid_format?

      checksum_info   = tracking_info["validation"]["checksum"]
      name            = checksum_info["name"]
      method_name     = "validates_#{name}?"

      ChecksumValidations.send(method_name, self.serial_number, self.check_digit, checksum_info)
    end

    define_method "info" do
      result = {}

      self.matches.names.each do |name|
        info = {
          :name => name,
          :value => self.matches[name],
        }

        additional = self.info_for(name)

        info[:additional] = additional

        result[name.underscore.to_sym] = info
      end

      result
    end

    define_method "info_for" do |group_name|
      group_value = self.matches[group_name]

      if tracking_info["additional"]
        additional = tracking_info["additional"].select do |info|
          info["regex_group_name"] === group_name
        end

        res = []

        additional.each do |add|
          matches = add["lookup"].find do |info|
            if info["matches"]
              group_value == info["matches"]
            elsif info["matches_regex"]
              group_value =~ Regexp.new(info["matches_regex"])
            end
          end

          unless matches.empty?
            res << matches
          end
        end

        res.flatten
      end
    end
  end

  return klass
end


tracking_number_types = []
named_group_info = {}

Dir.glob(File.join(File.dirname(__FILE__), "data/couriers/*.json")).each do |file|

  courier_code = File.basename(file, ".json")
  courier_info = JSON.parse(File.read(file))
  courier_name = courier_info["name"]
  courier_info["tracking_numbers"].each do |tracking_info|
    klass      = define_tracking_number_class(tracking_info)


    test_number = tracking_info["test_numbers"]["valid"][0]

    test_number.match(klass::VERIFY_PATTERN).names.each do |name|
      named_group_info[name] ||= 0
      named_group_info[name] += 1
    end

    klass.instance_eval do
      define_method "courier_code" do
        courier_code
      end
    end


    module_name = courier_name.gsub(/[^0-9A-Za-z]/, '')
    klass_name = tracking_info["name"].gsub(/[^0-9A-Za-z]/, '')

    puts courier_name
    puts klass_name
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
