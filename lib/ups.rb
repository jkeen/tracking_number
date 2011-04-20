class TrackingNumber
  class UPS < Base
    SEARCH_PATTERN = /(\b1\s*Z\s*(\w\s*){16,16}\b)/
    VERIFY_PATTERN = /^1Z(\w{15,15})(\w)$/
    
    def carrier
      :ups
    end

    def matches
       self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def valid_checksum?
      sequence = tracking_number.slice(2...17)
      check_digit = tracking_number.slice(17, 18)

      total = 0
      sequence.chars.each_with_index do |c, i|
        x = if c[/[0-9]/] # numeric
          c.to_i
        else
          (c[0].ord - 3) % 10
        end
        x *= 2 if i.odd?
        total += x
      end

      check = (total % 10)
      check = (10 - check) unless (check.zero?)

      return (check.to_i == check_digit.to_i)
    end

    def decode
      {:shipper_account =>  self.tracking_number.to_s.slice(2...8), 
       :service_type => self.tracking_number.to_s.slice(8...10),
       :package_identifier =>  self.tracking_number.to_s.slice(10...17),
       :check_digit => self.tracking_number.to_s.slice(17, 18)
      }
    end

    def service_type
      case decode[:service_type]
      when "01"
       "UPS United States Next Day Air (Red)"
      when "02"
       "UPS United States Second Day Air (Blue)"
      when "03"
       "UPS United States Ground"
      when "12"
       "UPS United States Third Day Select"
      when "13"
       "UPS United States Next Day Air Saver (Red Saver)"
      when "15"
       "UPS United States Next Day Air Early A.M."
      when "22"
       "UPS United States Ground - Returns Plus - Three Pickup Attempts"
      when "32"
       "UPS United States Next Day Air Early A.M. - COD"
      when "33"
       "UPS United States Next Day Air Early A.M. - Saturday Delivery, COD"
      when "41"
       "UPS United States Next Day Air Early A.M. - Saturday Delivery"
      when "42"
       "UPS United States Ground - Signature Required"
      when "44"
       "UPS United States Next Day Air - Saturday Delivery"
      when "66"
       "UPS United States Worldwide Express"
      when "72"
       "UPS United States Ground - Collect on Delivery"
      when "78"
       "UPS United States Ground - Returns Plus - One Pickup Attempt"
      when "90"
       "UPS United States Ground - Returns - UPS Prints and Mails Label"
      when "A0"
       "UPS United States Next Day Air Early A.M. - Adult Signature Required"
      when "A1"
       "UPS United States Next Day Air Early A.M. - Saturday Delivery, Adult Signature Required"
      when "A2"
       "UPS United States Next Day Air - Adult Signature Required"
      when "A8"
       "UPS United States Ground - Adult Signature Required"
      when "A9"
       "UPS United States Next Day Air Early A.M. - Adult Signature Required, COD"
      when "AA"
       "UPS United States Next Day Air Early A.M. - Saturday Delivery, Adult Signature Required, COD"
     end
    end
  end
end