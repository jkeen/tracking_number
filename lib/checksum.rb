module Checksum
  module Mod10
    def valid_checksum?
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

  module Mod7
    def valid_checksum?
      # standard mod 7 check
      sequence, check_digit = matches
      return true if sequence.to_i % 7 == check_digit.to_i
    end
  end

  module Mod11With8642357Weighting
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
