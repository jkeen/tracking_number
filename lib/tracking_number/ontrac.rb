module TrackingNumber
  class OnTrac < Base
    include Checksum::Mod10

    SEARCH_PATTERN = /(\b(C\s*)([0-9]\s*){14,14}\b)/
    VERIFY_PATTERN = /^(C[0-9]{13,13})([0-9])$/

    def carrier
      :ontrac
    end
  end
end
