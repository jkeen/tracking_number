module TrackingNumber
  class Unknown < Base
    def carrier
      :unknown
    end

    def courier_name
      "Unknown"
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

    def decode
      {}
    end

    def matching_additional
      {}
    end
  end
end
