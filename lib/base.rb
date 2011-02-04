class TrackingNumber
  class Base
    attr_accessor :tracking_number
    def initialize(tracking_number)
      @original_number = tracking_number
      @tracking_number = tracking_number.gsub(" ", "").upcase
    end

    def valid?
      return false unless valid_format?
      return false unless valid_checksum?
      return true
    end

    def valid_format?
      !matches.nil? && !matches.empty?
    end
    
    def decode
      {}
    end

    def matches
      []
    end

    def valid_checksum?
      false
    end

    def to_s
      self.tracking_number
    end
  end

  class Unknown < Base
    def carrier
      :unknown
    end
  end
end