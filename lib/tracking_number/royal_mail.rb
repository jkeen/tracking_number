module TrackingNumber
  class RoyalMail < Base
    include Checksum::Mod11With8642357Weighting

    VERIFY_PATTERN = /^([A-Z]{2}[0-9]{9}GB)$/
    SEARCH_PATTERN = [/(\b([A-Z]\s*){2}([0-9]\s*){9}(G\s*)(B\s*)\b)/]

    def carrier
      :royal_mail
    end

    def valid_optional_checks?
      identifier = self.tracking_number.to_s.slice(0...1)
      valid_starting_letters = %w(R A B J S V A F K Z T)

      return false unless valid_starting_letters.include?(identifier)
      return false unless self.tracking_number.end_with?("GB")
      return true
    end

    def decode
      {}
    end
  end
end
