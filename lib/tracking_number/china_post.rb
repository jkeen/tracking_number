# information on formats at these URLs:
#   http://track-chinapost.com
#   http://www.trackingnumber.org/china-post-tracking/

module TrackingNumber

  class ChinaPost < Base
    SEARCH_PATTERN = /(\b\w\s*\w\s*(\d\s*){9,9}\s*C\s*N\b)/
    VERIFY_PATTERN = /^\w\w(\d{9,9})CN$/
    LENGTH = 13

    def carrier
      :china_post
    end

    def matches
       self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def valid_checksum?
      return true
    end
  end

end