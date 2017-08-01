module ChecksumValidations
  class << self
    def validates_s10?(sequence, check_digit, extras = {})
      weighting = [8,6,4,2,3,5,9,7]

      total = 0
      sequence.chars.to_a.zip(weighting).each do |(a,b)|
        total += a.to_i * b
      end

      remainder = total % 11
      check = case remainder
      when 1
        0
      when 0
        5
      else
        11 - remainder
      end

      return check.to_i == check_digit.to_i
    end

    def validates_sum_product_with_weightings_and_modulo?(sequence, check_digit, extras = {})
      weighting = extras[:weightings] || []

      total = 0
      sequence.chars.to_a.zip(weighting).each do |(a,b)|
        total += a.to_i * b
      end
      return (total % extras[:modulo1] % extras[:modulo2]) == check_digit.to_i
    end

    def validates_mod10?(sequence, check_digit, extras = {})
      total = 0
      sequence.chars.each_with_index do |c, i|
        x = if c[/[0-9]/] # numeric
          c.to_i
        else
          (c[0].ord - 3) % 10
        end

        if extras[:odds_multiplier] && i.odd?
          x *= extras[:odds_multiplier].to_i
        elsif extras[:evens_multiplier] && i.even?
          x *= extras[:evens_multiplier].to_i
        end

        total += x
      end

      check = (total % 10)
      check = (10 - check) unless (check.zero?)

      return (check.to_i == check_digit.to_i)
    end

    def validates_mod7?(sequence, check_digit, extras = {})
      # standard mod 7 check
      return true if sequence.to_i % 7 == check_digit.to_i
    end
  end
end
