require 'checksum_validations'
require 'pry'
require 'active_support'

module TrackingNumber
  class Base
    attr_accessor :tracking_number
    attr_accessor :original_number

    def initialize(tracking_number)
      @original_number = tracking_number
      @tracking_number = tracking_number.strip.gsub(" ", "").upcase
    end

    def self.search(body)
      valids = self.scan(body).uniq.collect { |possible| new(possible) }.select { |t| t.valid? }

      uniques = {}
      valids.each do |t|
        uniques[t.tracking_number] = t unless uniques.has_key?(t.tracking_number)
      end

      uniques.values
    end

    def self.scan(body)
      matches = body.match(self.const_get(:SEARCH_PATTERN))

      if matches
        [matches[0]]
      else
        []
      end
    end

    def match_group(name)
      self.matches[name].gsub(/\s/, '')
    end

    def serial_number
      return match_group("SerialNumber") unless self.class.const_get("VALIDATION")

      format_info   = self.class.const_get(:VALIDATION)[:serial_number_format]
      raw_serial    = match_group("SerialNumber")

      if format_info
        if format_info[:prepend_if] && raw_serial.match(Regexp.new(format_info[:prepend_if][:matches_regex]))
          return "#{format_info[:prepend_if][:content]}#{raw_serial}"
        elsif format_info[:prepend_if_missing]

        end
      end

      return raw_serial
    end

    def courier_code
      self.class.const_get(:COURIER_CODE).to_sym
    end

    alias_method :carrier, :courier_code

    def check_digit
      match_group("CheckDigit")
    end

    def courier
      matching_additional["Courier"]
    end

    def service_type
      matching_additional["Service Type"]
    end

    def package_info
      match_group("ContainerType")
    end

    def destination
      match_group("DestinationZip")
    end

    def shipper_info
      match_group("ShipperInfo")
    end

    def valid?
      return false unless valid_format?
      return false unless valid_checksum?
      return false unless valid_optional_checks?
      return true
    end

    def decode
      decoded = {}
      self.matches.names.each do |name|
        sym = name.underscore.to_sym
        decoded[sym] = self.matches[name]
      end

      decoded
    end

    def matches
      if self.class.constants.include?(:VERIFY_PATTERN)
        self.tracking_number.match(self.class.const_get(:VERIFY_PATTERN))
      else
        []
      end
    end

    def valid_format?
      !matches.nil?
    end

    def valid_optional_checks?
      additional_check = self.class.const_get("VALIDATION")[:additional]
      return true unless additional_check

      exist_checks = (additional_check[:exists] ||= [])
      exist_checks.all? { |w| matching_additional[w] }
    end

    def valid_checksum?
      return false unless self.valid_format?

      checksum_info   = self.class.const_get(:VALIDATION)[:checksum]
      name            = checksum_info[:name]
      method_name     = "validates_#{name}?"

      ChecksumValidations.send(method_name, serial_number, check_digit, checksum_info)
    end

    def to_s
      self.tracking_number
    end

    def inspect
      "#<%s:%#0x %s>" % [self.class.to_s, self.object_id, tracking_number]
    end

    def matching_additional
      additional = self.class.const_get(:ADDITIONAL) || []

      relevant_sections = {}

      additional.each do |info|
        if value = self.matches[info[:regex_group_name]].gsub(/\s/, "")
          # has matching value
          matches = info[:lookup].find do |info|
            if info[:matches]
              value == info[:matches]
            elsif info[:matches_regex]
              value =~ Regexp.new(info[:matches_regex])
            end
          end

          relevant_sections[info[:name]] = matches
        end
      end

      relevant_sections
    end
  end

  class Unknown < Base
    def carrier
      :unknown
    end

    def courier
      :unknown
    end

    def valid?
      false
    end

    def valid_format?
      false
    end

    def valid_checksum?
      false
    end
  end
end
