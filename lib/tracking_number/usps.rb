# 9341989692090075346172, 9341989675090049647994
# 9400110699047012542640, 9400110200828675856233

# USPS Tracking®
# => 9400 1000 0000 0000 0000 00

# 9249090109401231618933, 9249090109401231618933

# Priority Mail®
# => 9205 5000 0000 0000 0000 00

# Certified Mail®
# => 9407 3000 0000 0000 0000 00

# Collect On Delivery Hold For Pickup
# => 9303 3000 0000 0000 0000 00

# Global Express Guaranteed®	82 000 000 00

# Priority Mail Express®
# => 9270 1000 0000 0000 0000 00

# Registered Mail™
# => 9208 8000 0000 0000 0000 00
# Signature Confirmation™
# => 9202 1000 0000 0000 0000 00

module TrackingNumber
  class USPS < Base
    def carrier
      :usps
    end
  end

  class USPS91 < USPS
    SEARCH_PATTERN = [/(\b(?:420\s*\d{5})?9\s*[1-5]\s*(?:(?:(?:[0-9]\s*){20}\b)|(?:(?:[0-9]\s*){24}\b)))/, /(\b([0-9]\s*){20}\b)/]
    VERIFY_PATTERN = /^(?:420\d{5})?(9[1-5](?:[0-9]{19}|[0-9]{23}))([0-9])$/

    # Sometimes these numbers will appear without the leading 91, 93, or 94, though, so we need to account for that case

    def decode
      # Application ID: 91, 93, 94 or 95
      # Service Code: 2 Digits
      # Mailer Id: 8 Digits
      # Package Id: 9 Digits
      # Checksum: 1 Digit

      base_tracking_number = self.tracking_number.to_s.gsub(/^420\d{5}/, '')

      {:application_id => base_tracking_number.to_s.slice(0...2),
       :service_code =>  base_tracking_number.to_s.slice(2...4),
       :mailer_id => base_tracking_number.to_s.slice(4...12),
       :package_identifier =>  base_tracking_number.to_s.slice(12...21),
       :check_digit => base_tracking_number.slice(21...22)
      }
    end

    def matches
      if self.tracking_number =~ /^(420\d{5})?9[1-5]/
        self.tracking_number.scan(VERIFY_PATTERN).flatten
      else
        "91#{self.tracking_number}".scan(VERIFY_PATTERN).flatten
      end
    end

    def valid_checksum?
      if self.tracking_number =~ /^(420\d{5})?9[1-5]/
        return true if weighted_usps_checksum_valid?(tracking_number)
      else
        if weighted_usps_checksum_valid?("91#{self.tracking_number}")
          # set the tracking number to the 91 format if it passes this test
          self.tracking_number = "91#{self.tracking_number}"
          return true
        end
      end
    end

    private

    def weighted_usps_checksum_valid?(sequence)
      chars = sequence.gsub(/^420\d{5}/, '').chars.to_a
      check_digit = chars.pop

      total = 0
      chars.reverse.each_with_index do |c, i|
        x = c.to_i
        x *= 3 if i.even?

        total += x
      end

      check = total % 10
      check = 10 - check unless (check.zero?)
      return true if check == check_digit.to_i
    end
  end

  class USPS20 < USPS
    # http://www.usps.com/cpim/ftp/pubs/pub109.pdf (Publication 109. Extra Services Technical Guide, pg. 19)
    # http://www.usps.com/cpim/ftp/pubs/pub91.pdf (Publication 91. Confirmation Services Technical Guide pg. 38)

    SEARCH_PATTERN = /(\b([0-9]\s*){20,20}\b)/
    VERIFY_PATTERN = /^([0-9]{2,2})([0-9]{9,9})([0-9]{8,8})([0-9])$/

    def decode
      {:service_code =>  self.tracking_number.to_s.slice(0...2),
       :mailer_id => self.tracking_number.to_s.slice(2...11),
       :package_identifier =>  self.tracking_number.to_s.slice(11...19),
       :check_digit => self.tracking_number.slice(19...20)
      }
    end

    def service_type
      case decode[:service_code]
      when "71"
        "Certified Mail"
      when "73"
        "Insured Mail"
      when "77"
        "Registered Mail"
      when "81"
        "Return Receipt for Merchandise"
      end
    end

    def valid_checksum?
      chars = tracking_number.chars.to_a
      check_digit = chars.pop

      total = 0
      chars.reverse.each_with_index do |c, i|
        x = c.to_i
        x *= 3 if i.even?
        total += x
      end

      check = total % 10
      check = 10 - check unless (check.zero?)
      return true if check == check_digit.to_i
    end
  end

  # Priority Mail Express International®
  # => EC 000 000 000 US

  # Priority Mail International®
  # => CP 000 000 000 US

  # Priority Mail Express
  # => EA 000 000 000 US

  class USPS13 < USPS
    include Checksum::Mod11With8642357Weighting

    SEARCH_PATTERN = /(\b([A-Z]\s*){2,2}([0-9]\s*){9,9}([A-Z]\s*){2,2}\b)/
    VERIFY_PATTERN = /^([A-Z]{2,2})([0-9]{9,9})([A-Z]{2,2})$/

    def decode
      {:service_code => self.tracking_number.to_s.slice(0...2),
       :package_identifier =>  self.tracking_number.to_s.slice(3...10),
       :check_digit => self.tracking_number.slice(11...11),
       :shipped_from => self.tracking_number.slice(12...13)
      }
    end

    def service_type
      case decode[:service_code]
      when "EC"
        "Priority Mail Express International"
      when "CP"
        "Priority Mail International"
      when "EA"
        "Priority Mail Express"
      end
    end

    def valid_optional_checks?
      identifier = self.tracking_number.to_s.slice(0...1)
      valid_starting_letters = %w(R A E D T V C L G M)

      return false unless valid_starting_letters.include?(identifier)
      return false unless self.tracking_number.end_with?("US")
      return true
    end
  end

  class USPSTest < USPS
    # USPS Test Number From Easypost. IE: 9499 9071 2345 6123 4567 81
    SEARCH_PATTERN = /(\b([0-9]\s*){22,22}\b)/
    VERIFY_PATTERN = SEARCH_PATTERN

    def valid_checksum?
      sequence = tracking_number.scan(/[0-9]+/).flatten.join
      return sequence == "9499907123456123456781"
    end
  end
end
