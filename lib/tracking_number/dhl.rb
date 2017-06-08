module TrackingNumber
  class DHL < Base
    include Checksum::Mod7

    def carrier
      :dhl
    end
  end

  #DHL Air (a division of DHL Express) have 11 digit numbers
  class DHLExpressAir < DHL
    SEARCH_PATTERN = /(\b([0-9]\s*){11,11}\b)/
    VERIFY_PATTERN = /^([0-9]{10,10})([0-9])$/
  end

  #DHL Express numbers are 10 digits long
  # http://www.dhl.co.uk/content/dam/downloads/uk/Express/PDFs/developer_centre/dhlis9_shipment_and_piece_ranges_v1.3.pdf
  class DHLExpress < DHL
    SEARCH_PATTERN = /(\b([0-9]\s*){10,10}\b)/
    VERIFY_PATTERN = /^([0-9]{9,9})([0-9])$/
  end
end
