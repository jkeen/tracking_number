# Identify if tracking numbers are valid, and which service they belong to

# Information on validating tracking numbers found here:
# http://answers.google.com/answers/threadview/id/207899.html

class TrackingNumber
  SEARCH_PATTERNS = {
    :ups => /\b1Z\w{16,16}\b/,
    :fedex_express => /\b[0-9]{12,12}\b/,
    :fedex_ground_96 => /\b96[0-9]{20,20}\b/,
    :fedex_ground_sscc18 => /\b[0-9]{18,18}\b/,
    :dhl => /\b[0-9]{11,11}\b/,
    :usps => /\b[0-9]{22,22}\b/
  }

  VERIFY_PATTERNS = {
    :ups => /^1Z(\w{15,15})(\w)$/,
    :fedex_express => /^([0-9]{11,11})([0-9])$/,
    :fedex_ground_96 => /^96[0-9]{5,5}([0-9]{14,14})([0-9])$/,
    :fedex_ground_sscc18 => /^[0-9]{2,2}([0-9]{15,15})([0-9])$/,
    :dhl => /^([0-9]{10,10})([0-9])$/,
    :usps => /^([0-9]{21,21})([0-9])/
  }

  def self.search(body)
   possibles = SEARCH_PATTERNS.values.collect { |pattern| 
     body.scan(pattern)
   }.uniq.flatten
   
   possibles.collect { |possible| TrackingNumber.new(possible) }.select { |t| t.valid? }
  end

  def initialize(tracking_number)
   @tracking_number = tracking_number.to_s.upcase.gsub(/\s/,"")
    end

    def valid?
      carrier != :unknown
    end

    def carrier
      @carrier = if ups?(@tracking_number)
        :ups
      elsif fedex_express?(@tracking_number)
        :fedex
      elsif fedex_ground_96?(@tracking_number)
        :fedex
      elsif fedex_ground_sscc18?(@tracking_number)
        :fedex
      elsif usps?(@tracking_number)
        :usps
      elsif dhl?(@tracking_number)
        :dhl
      else
        :unknown
      end
    end

    def tracking_number
      @tracking_number
    end

    def to_s
      @tracking_number
    end

    private

      def ups?(tracking_number)
        results = tracking_number.scan(VERIFY_PATTERNS[:ups])
        return false if results.nil? || results.empty?

        sequence, check_digit = results.flatten
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

        return true if (check.to_i == check_digit.to_i)
      end


      def fedex_express?(tracking_number)
        results = tracking_number.scan(VERIFY_PATTERNS[:fedex_express]).flatten
        return false if results.nil? || results.empty?
        sequence, check = results

        sequence = sequence.chars.to_a.map(&:to_i)
        total = 0
        sequence.zip([3,1,7,3,1,7,3,1,7,3,1]).collect { |pair| pair[0] * pair[1] }.each { |t| total += t.to_i }
        return true if (total % 11) == check.to_i
      end

      def fedex_ground_96?(tracking_number)
        # 22 numbers
        # http://fedex.com/us/solutions/ppe/FedEx_Ground_Label_Layout_Specification.pdf
        # 96 - UCC/EAN Application Identifier
        # [0-9]{2,2} - SCNC
        # [0-9]{3,3} - Class Of Service

        # [0-9]{7,7} - RPS Shipper ID (used in calculation)
        # [0-9]{7,7} - Package Number (used in calculation)

        # [0-9]      - Check Digit
        results = tracking_number.scan(VERIFY_PATTERNS[:fedex_ground_96]).flatten
        return false if results.nil? || results.empty?

        sequence, check_digit = results.flatten
        total = 0
        sequence.chars.to_a.reverse.map(&:to_i).each_with_index do |x, i|
          x *= 3 if i.even?
          total += x
        end
        check = total % 10
        check = (10 - check) unless (check.zero?)
        return true if check == check_digit.to_i
      end

      def fedex_ground_sscc18?(tracking_number)
        # [0-9]{2,2} - Not used
        # [0-9]{15, 15} - used for calculation
        results = tracking_number.scan(VERIFY_PATTERNS[:fedex_ground_sscc18]).flatten
        return false if results.nil? || results.empty?
        sequence, check_digit = results
        total = 0
        sequence.chars.to_a.map(&:to_i).reverse.each_with_index do |x, i|
          x *= 3 if i.even?
          total += x
        end

        check = total % 10
        check = (10 - check) unless (check.zero?)
        return true if check == check_digit.to_i
      end

      def dhl?(tracking_number)
        # standard mod 7 check
        results = tracking_number.scan(VERIFY_PATTERNS[:dhl]).flatten
        return false if results.nil? || results.empty?

        sequence, check_digit = results
        return true if sequence.to_i % 7 == check_digit.to_i
      end

      def usps?(tracking_number)
        # standard mod 10 check
        results = tracking_number.scan(VERIFY_PATTERNS[:usps]).flatten
        return false if results.nil? || results.empty?

        sequence, check_digit = results
        total = 0
        sequence.chars.to_a.reverse.each_with_index do |c, i|
          x = c.to_i
          x *= 3 if i.even?

          total += x
        end

        check = total % 10
        check = 10 - check unless (check.zero?)
        return true if check == check_digit.to_i
      end
      end
