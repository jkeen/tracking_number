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
      valids = self.scan(body.gsub(' ','')).uniq.collect { |possible| new(possible) }.select { |t| t.valid? }

      uniques = {}
      valids.each do |t|
        uniques[t.tracking_number] = t unless uniques.has_key?(t.tracking_number)
      end

      uniques.values
    end

    def self.scan(body)
      patterns = [self.const_get("SEARCH_PATTERN")].flatten
      possibles = patterns.collect do |pattern|
        body.scan(pattern).uniq.collect { |a| a.join("") }
      end

      possibles.flatten.compact.uniq
    end

    def service_type

    end

    def package_info

    end

    def destination

    end

    def shipper_info

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
        self.tracking_number.match(self.class.const_get("VERIFY_PATTERN"))
      else
        []
      end
    end

    def valid_format?
      !matches.nil?
    end

    def valid_optional_checks?
      true
    end

    def valid_checksum?
      false
    end

    def to_s
      self.tracking_number
    end

    def inspect
      "#<%s:%#0x %s>" % [self.class.to_s, self.object_id, tracking_number]
    end
  end

  class Unknown < Base
    def carrier
      :unknown
    end
  end
end
