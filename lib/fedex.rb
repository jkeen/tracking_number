class TrackingNumber
  class FedEx < Base
    def carrier
      :fedex
    end
  end

  class FedExExpress < FedEx
    SEARCH_PATTERN = /(\b([0-9]\s*){12,12}\b)/
    VERIFY_PATTERN = /^([0-9]{11,11})([0-9])$/

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def valid_checksum?
      sequence = tracking_number.chars.to_a
      check = sequence.pop
      total = 0
      sequence.zip([3,1,7,3,1,7,3,1,7,3,1]).collect { |pair| pair[0].to_i * pair[1].to_i }.each { |t| total += t.to_i }
      return (total % 11) == check.to_i
    end
  end

  class FedExGround96 < FedEx
    SEARCH_PATTERN = /(\b9\s*6\s*([0-9]\s*){20,20}\b)/
    VERIFY_PATTERN = /^96[0-9]{5,5}([0-9]{14,14})([0-9])$/

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def decode
      {:application_id => self.tracking_number.to_s.slice(0...2),
       :serial_container =>  self.tracking_number.to_s.slice(2...4), 
       :service_code => self.tracking_number.to_s.slice(4...7),
       :shipper_id =>  self.tracking_number.to_s.slice(7...14),
       :package_identifier =>  self.tracking_number.to_s.slice(14...21),
       :check_digit => self.tracking_number.slice(21...22)
      }
    end

    def valid_checksum?
      # 22 numbers
      # http://fedex.com/us/solutions/ppe/FedEx_Ground_Label_Layout_Specification.pdf
      # 96 - UCC/EAN Application Identifier
      
      # [0-9]{2,2} - SCNC
      # [0-9]{3,3} - Class Of Service
      # [0-9]{7,7} - RPS Shipper ID (used in calculation)
      # [0-9]{7,7} - Package Number (used in calculation)
      # [0-9]      - Check Digit
      sequence, check_digit = matches

      total = 0
      sequence.chars.to_a.map(&:to_i).reverse.each_with_index do |x, i|
        x *= 3 if i.even?
        total += x
      end

      check = total % 10
      check = (10 - check) unless (check.zero?)
      return true if check == check_digit.to_i
    end
  end

  class FedExGround18 < FedEx
    SEARCH_PATTERN = /(\b([0-9]\s*){18,18}\b)/
    VERIFY_PATTERN = /^[0-9]{2,2}([0-9]{15,15})([0-9])$/

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def decode
      {:application_id => self.tracking_number.to_s.slice(0...2),
       :serial_container =>  self.tracking_number.to_s.slice(1...2), 
       :service_code => self.tracking_number.to_s.slice(2...3),
       :shipper_id =>  self.tracking_number.to_s.slice(3...10),
       :package_identifier =>  self.tracking_number.to_s.slice(10...17),
       :check_digit => self.tracking_number.slice(17...18)
      }
    end
    
    def valid_checksum?
      # [0-9]{2,2} - Not used
      # [0-9]{15, 15} - used for calculation
      
      sequence = tracking_number.chars.to_a.map(&:to_i)
      check_digit = sequence.pop
      total = 0
      sequence.reverse.each_with_index do |x, i|
        x *= 3 if i.even?
        total += x
      end
      check = total % 10
      check = (10 - check) unless (check.zero?)
      return true if check == check_digit.to_i
    end
  end

end