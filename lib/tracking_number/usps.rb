module TrackingNumber
  class USPS < Base
    def carrier
      :usps
    end
  end

  class USPS91 < USPS
    SEARCH_PATTERN = [/(\b9\s*[145]\s*(([0-9]\s*){20,20}\b))/, /(\b([0-9]\s*){20,20}\b)/]
    VERIFY_PATTERN = /^(9[145][0-9]{19,19})([0-9])$/

    # Sometimes these numbers will appear without the leading 91 or 94, though, so we need to account for that case

    def decode
      # Application ID: 91 or 94 or 95
      # Service Code: 2 Digits
      # Mailer Id: 8 Digits
      # Package Id: 9 Digits
      # Checksum: 1 Digit

      {:application_id => self.tracking_number.to_s.slice(0...2),
       :service_code =>  self.tracking_number.to_s.slice(2...4),
       :mailer_id => self.tracking_number.to_s.slice(4...12),
       :package_identifier =>  self.tracking_number.to_s.slice(12...21),
       :check_digit => self.tracking_number.slice(21...22)
      }
    end

    def matches
      if self.tracking_number =~ /^9[145]/
        self.tracking_number.scan(VERIFY_PATTERN).flatten
      else
        "91#{self.tracking_number}".scan(VERIFY_PATTERN).flatten
      end
    end

    def valid_checksum?
      if self.tracking_number =~ /^9[145]/
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
      chars = sequence.chars.to_a
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

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

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

  class USPS13 < USPS
    SEARCH_PATTERN = /(\b([A-Z]\s*){2,2}([0-9]\s*){9,9}([A-Z]\s*){2,2}\b)/
    VERIFY_PATTERN = /^([A-Z]{2,2})([0-9]{9,9})([A-Z]{2,2})$/

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def valid_checksum?
      sequence = tracking_number.scan(/[0-9]+/).flatten.join
      chars = sequence.chars.to_a
      check_digit = chars.pop.to_i

      sum = 0
      chars.zip([8,6,4,2,3,5,9,7]).each do |pair|
        sum += (pair[0].to_i * pair[1].to_i)
      end

      remainder = sum % 11
      check = case remainder
      when 1
        0
      when 0
        5
      else
        11 - remainder
      end

      return check == check_digit
    end
  end
end
