module TrackingNumber
  class OnTrac < Base
    SEARCH_PATTERN = /(\b(C\s*)([0-9]\s*){14,14}\b)/
    VERIFY_PATTERN = /^(C[0-9]{13,13})([0-9])$/
    def carrier
      :ontrac
    end

    def matches
      self.tracking_number.scan(VERIFY_PATTERN).flatten
    end

    def valid_checksum?
      # checksum calculation is the same as UPS
      sequence, check_digit = matches

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
  end
end
