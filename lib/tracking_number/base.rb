require 'checksum'
require 'pry'
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
      patterns = [self.const_get("SEARCH_PATTERN")].flatten
      possibles = patterns.collect do |pattern|
        body.scan(pattern).uniq.flatten
      end

      possibles.flatten.compact.uniq
    end

    def valid?
      return false unless valid_format?
      return false unless valid_checksum?
      return false unless valid_optional_checks?
      return true
    end

    def valid_format?
      !matches.nil? && !matches.empty?
    end

    def decode
      {}
    end

    def matches
      if self.class.constants.include?(:VERIFY_PATTERN)
        self.tracking_number.scan(self.class.const_get("VERIFY_PATTERN")).flatten
      else
        []
      end
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
