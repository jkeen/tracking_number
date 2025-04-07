module TrackingNumber
  module ChecksumValidations
    class << self
      def validates_s10?(sequence, check_digit, extras = {})
        weighting = [8,6,4,2,3,5,9,7]

        total = 0
        sequence.chars.to_a.zip(weighting).each do |(a,b)|
          total += a.to_i * b.to_i
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

      def validates_mod_37_36?(sequence, check_digit, extras = {})
        # From https://esolutions.dpd.com/dokumente/DPD_Parcel_Label_Specification_2.4.1_EN.pdf

        mod = 36
        weights = {A: 10, B: 11, C: 12, D: 13, E: 14, F: 15, G: 16, H: 17, I: 18, J: 19, K: 20, L: 21, M: 22, N: 23, O: 24, P: 25, Q: 26, R: 27, S: 28, T: 29, U: 30, V: 31, W: 32, X: 33, Y: 34, Z: 35}
        cd = mod
        sequence.chars.to_a.each do |char, i|
          val = (char =~ /[A-Za-z]/  ? weights[char.to_sym] : char.to_i)

          cd = val + cd
          cd = cd - mod if cd > mod
          cd = cd * 2
          cd = cd - (mod + 1) if cd > mod
        end

        cd = (mod + 1) - cd
        cd = 0 if cd == mod
        computed = if cd >= 10
                     weights.find { |a, val| val == cd }[0].to_s
                   else
                     cd.to_s
                   end

        computed == check_digit
      end

      def validates_luhn?(sequence, check_digit, extras = {})
        total = 0
        sequence.chars.reverse.each_with_index do |c, i|
          x = c.to_i

          if i.even?
            x *= 2
          end

          if x > 9
            x -= 9
          end

          total += x
        end

        check = (total % 10)
        check = (10 - check) unless (check.zero?)

        return (check.to_i == check_digit.to_i)
      end
    end
  end
end
