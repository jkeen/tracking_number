module TrackingNumber
  class RRDonnelley < Base
    def carrier
      :rrdonnelley
    end
  end

  class RRDonnelleyStandard < RRDonnelley
    SEARCH_PATTERN = /(\b([0-9]\s*){12,12}\b)/
    VERIFY_PATTERN = /(RRD)\d{15}$/
    LENGTH = 18

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end
  end
end
