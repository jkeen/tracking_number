module TrackingNumber
  class Base
    attr_accessor :tracking_number
    attr_accessor :original_number

    def initialize(tracking_number)
      @original_number = tracking_number
      @tracking_number = tracking_number.strip.gsub(" ", "").upcase
    end

    def self.search(body)
      valids = self.scan(body).uniq.collect { |possible| new(possible) }.select { |t| t.valid? }

      uniques = {}
      valids.each do |t|
        uniques[t.tracking_number] = t unless uniques.has_key?(t.tracking_number)
      end

      uniques.values
    end

    def self.scan(body)
      # matches with match groups within the match data
      matches = []

      body.scan(self.const_get(:SEARCH_PATTERN)){
        #get the match data instead, which is needed with these types of regexes
        matches << $~
      }

      if matches
        matches.collect { |m| m[0] }
      else
        []
      end
    end

    def self.tracking_url(*trackers)
      if not trackers.all? { |t| t.class == self }
        raise ArgumentError, "all tracking numbers must be of same class"
      end
      url = nil
      courier = trackers.first.matching_additional["Courier"]
      if courier
        url = courier[:tracking_url]
      else
        if self.const_defined?(:TRACKING_URL)
          url = self.const_get(:TRACKING_URL)
        end
      end
      if url
        url.sub('%s', trackers.map(&:tracking_number).join(','))
      end
    end

    def serial_number
      return match_group("SerialNumber") unless self.class.const_get("VALIDATION")

      format_info   = self.class.const_get(:VALIDATION)[:serial_number_format]
      raw_serial    = match_group("SerialNumber")

      if format_info
        if format_info[:prepend_if] && raw_serial.match(Regexp.new(format_info[:prepend_if][:matches_regex]))
          return "#{format_info[:prepend_if][:content]}#{raw_serial}"
        elsif format_info[:prepend_if_missing]

        end
      end

      return raw_serial
    end

    def check_digit
      match_group("CheckDigit")
    end

    def decode
      decoded = {}
      (self.matches.try(:names) || []).each do |name|
        sym = name.underscore.to_sym
        decoded[sym] = self.matches[name]
      end

      decoded
    end

    def valid?
      return false unless valid_format?
      return false unless valid_checksum?
      return false unless valid_optional_checks?
      return true
    end

    def valid_format?
      !matches.nil?
    end

    def valid_optional_checks?
      additional_check = self.class.const_get("VALIDATION")[:additional]
      return true unless additional_check

      exist_checks = (additional_check[:exists] ||= [])
      exist_checks.all? { |w| matching_additional[w] }
    end

    def valid_checksum?
      return false unless self.valid_format?
      checksum_info   = self.class.const_get(:VALIDATION)[:checksum]
      return true unless checksum_info

      name            = checksum_info[:name]
      method_name     = "validates_#{name}?"

      TrackingNumber::ChecksumValidations.send(method_name, serial_number, check_digit, checksum_info)
    end

    def to_s
      self.tracking_number
    end

    def inspect
      "#<%s:%#0x %s>" % [self.class.to_s, self.object_id, tracking_number]
    end

    def info
      Info.new({
        :courier => courier_info,
        :service_type => service_type,
        :service_description => service_description,
        :destination_zip => destination_zip,
        :shipper_id => shipper_id,
        :package_type => package_type
      })
    end

    def courier_code
      self.class.const_get(:COURIER_CODE).to_sym
    end

    def courier_name
      if matching_additional["Courier"]
        matching_additional["Courier"][:courier]
      else
        if self.class.constants.include?(:COURIER_INFO)
          self.class.const_get(:COURIER_INFO)[:name]
        end
      end
    end

    alias_method :carrier, :courier_code #OG tracking_number gem used :carrier.
    alias_method :carrier_code, :courier_code
    alias_method :carrier_name, :courier_name

    def courier_info
      basics = {:name => courier_name, :code => courier_code}

      if info = matching_additional["Courier"]
        basics.merge!(:name => info[:courier], :url => info[:courier_url], :country => info[:country])
      end

      @courier ||= Info.new(basics)
    end

    def service_type
      if matching_additional["Service Type"]
        @service_type ||= Info.new(matching_additional["Service Type"]).name
      end
    end

    def service_description
      if matching_additional["Service Type"]
        @service_description ||= Info.new(matching_additional["Service Type"]).description
      end
    end

    def package_type
      if matching_additional["Container Type"]
        @package_type ||= Info.new(matching_additional["Container Type"]).name
      end
    end

    def destination_zip
      match_group("DestinationZip")
    end

    def shipper_id
      match_group("ShipperId")
    end

    def tracking_url
      self.class.tracking_url self
    end

    def matching_additional
      additional = self.class.const_get(:ADDITIONAL) || []

      relevant_sections = {}

      additional.each do |info|
        if self.matches && self.matches.length > 0
          if value = self.matches[info[:regex_group_name]].gsub(/\s/, "")
            # has matching value
            matches = info[:lookup].find do |i|
              if i[:matches]
                value == i[:matches]
              elsif i[:matches_regex]
                value =~ Regexp.new(i[:matches_regex])
              end
            end

            relevant_sections[info[:name]] = matches
          end
        end
      end

      relevant_sections
    end

    protected

    def matches
      if self.class.constants.include?(:VERIFY_PATTERN)
        self.tracking_number.match(self.class.const_get(:VERIFY_PATTERN))
      else
        []
      end
    end

    def match_group(name)
      begin
        self.matches[name].gsub(/\s/, '')
      rescue
        nil
      end
    end

  end
end
