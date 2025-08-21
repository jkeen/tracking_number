module TrackingNumber
  class Base
    attr_accessor :tracking_number, :original_number, :partner, :partner_data

    PartnerStruct = Struct.new(:shipper, :carrier)

    def initialize(tracking_number)
      @original_number = tracking_number
      @tracking_number = tracking_number.strip.gsub(' ', '').upcase
    end

    def self.search(body)
      valids = scan(body).uniq.collect { |possible| new(possible) }.select { |t| t.valid? }

      uniques = {}
      valids.each do |t|
        uniques[t.tracking_number] = t unless uniques.has_key?(t.tracking_number)
      end

      uniques.values
    end

    def self.scan(body)
      # matches with match groups within the match data
      matches = []

      body.upcase.scan(const_get(:SEARCH_PATTERN)) do
        # get the match data instead, which is needed with these types of regexes
        matches << $~
      end

      if matches
        matches.collect { |m| m[0] }
      else
        []
      end
    end

    def serial_number
      return match_group('SerialNumber') unless self.class.const_get('VALIDATION')

      format_info   = self.class.const_get(:VALIDATION)[:serial_number_format]
      raw_serial    = match_group('SerialNumber')

      if format_info && format_info[:prepend_if] && raw_serial.match(Regexp.new(format_info[:prepend_if][:matches_regex]))
        return "#{format_info[:prepend_if][:content]}#{raw_serial}"
      # elsif format_info && format_info[:prepend_if_missing]

      end

      raw_serial
    end

    def check_digit
      match_group('CheckDigit')
    end

    def decode
      decoded = {}
      (matches.try(:names) || []).each do |name|
        sym = name.underscore.to_sym
        decoded[sym] = matches[name]
      end

      decoded
    end

    def valid?
      return false unless valid_format?
      return false unless valid_checksum?
      return false unless valid_optional_checks?

      true
    end

    def valid_format?
      !matches.nil?
    end

    def valid_optional_checks?
      additional_check = self.class.const_get('VALIDATION')[:additional]
      return true unless additional_check

      exist_checks = (additional_check[:exists] ||= [])
      exist_checks.all? { |w| matching_additional[w] }
    end

    def valid_checksum?
      return false unless valid_format?

      checksum_info = self.class.const_get(:VALIDATION)[:checksum]
      return true unless checksum_info

      name            = checksum_info[:name]
      method_name     = "validates_#{name}?"

      TrackingNumber::ChecksumValidations.send(method_name, serial_number, check_digit, checksum_info)
    end

    def checksum?
      !!self.class.const_get(:VALIDATION)[:checksum]
    end

    LENGTH_WEIGHT = 0.1
    CHECKSUM_WEIGHT = 5.0

    def confidence
      (checksum? ? CHECKSUM_WEIGHT : 0) + tracking_number.length * LENGTH_WEIGHT
    end

    def to_s
      tracking_number
    end

    def inspect
      format('#<%s:%#0x %s%s>', self.class.to_s, object_id, tracking_number, partnership_inspect)
    end

    def partnership_inspect
      if shipper? ^ carrier?
        ' (partnership)'
      else
        ''
      end
    end

    def info
      Info.new({
                 courier: courier_info,
                 service_type: service_type,
                 service_description: service_description,
                 destination_zip: destination_zip,
                 shipper_id: shipper_id,
                 package_type: package_type,
                 tracking_url: tracking_url,
                 partners: partners,
                 decode: decode
               })
    end

    def courier_code
      self.class.const_get(:COURIER_CODE).to_sym
    end

    def courier_name
      if matching_additional['Courier']
        matching_additional['Courier'][:courier]
      elsif self.class.constants.include?(:COURIER_INFO)
        self.class.const_get(:COURIER_INFO)[:name]
      end
    end

    alias carrier courier_code # OG tracking_number gem used :carrier.
    alias carrier_code courier_code
    alias carrier_name courier_name

    def courier_info
      basics = { name: courier_name, code: courier_code }

      if info = matching_additional['Courier']
        basics.merge!(name: info[:courier], url: info[:courier_url], country: info[:country])
      end

      @courier ||= Info.new(basics)
    end

    def partnership?
      partners.present?
    end

    def shipper?
      return true unless partnership?

      partners.shipper == self
    end

    def carrier?
      return true unless partnership?

      partners.carrier == self
    end

    def partners
      return unless self.class.const_defined?(:PARTNERS)

      partner_hash = {}

      return unless (partner_tn = find_matching_partner)

      possible_twin = partner_tn.send(:find_matching_partner)

      if possible_twin.instance_of?(self.class) && possible_twin.tracking_number == tracking_number
        partner_hash[partner_data[:partner_type].to_sym] = partner_tn
        partner_hash[partner_tn.partner_data[:partner_type].to_sym] = self
      end

      PartnerStruct.new(partner_hash[:shipper], partner_hash[:carrier]) if partner_hash.keys.any?
    end

    def service_type
      @service_type ||= Info.new(matching_additional['Service Type']).name if matching_additional['Service Type']
    end

    def service_description
      @service_description ||= Info.new(matching_additional['Service Type']).description if matching_additional['Service Type']
    end

    def package_type
      @package_type ||= Info.new(matching_additional['Container Type']).name if matching_additional['Container Type']
    end

    def destination_zip
      match_group('DestinationZip')
    end

    def shipper_id
      match_group('ShipperId')
    end

    def tracking_url
      url = nil
      if matching_additional['Courier']
        url = matching_additional['Courier'][:tracking_url]
      elsif self.class.const_defined?(:TRACKING_URL)
        url = self.class.const_get(:TRACKING_URL)
      end

      url.sub('%s', tracking_number) if url
    end

    def matching_additional
      additional = self.class.const_get(:ADDITIONAL) || []

      relevant_sections = {}

      additional.each do |additional_info|
        next unless matches && matches.length > 0 # skip if no match groups

        value = matches[additional_info[:regex_group_name]].gsub(/\s/, '') # match is empty
        next unless value
        next unless additional_info[:lookup]

        matches = additional_info[:lookup].find do |i|
          if i[:matches]
            value == i[:matches]
          elsif i[:matches_regex]
            value =~ Regexp.new(i[:matches_regex])
          end
        end

        # has matching value
        relevant_sections[additional_info[:name]] = matches
      end

      relevant_sections
    end

    protected

    def match_all(items)
      items.all? do |i|
        if i[:matches] && matches[i[:regex_group_name]]
          matches[i[:regex_group_name]] == i[:matches]
        elsif i[:matches_regex] && matches[i[:regex_group_name]]
          matches[i[:regex_group_name]] =~ Regexp.new(i[:matches_regex])
        else
          false
        end
      end
    end

    def match_any(items)
      items.find do |i|
        if i[:matches] && matches[i[:regex_group_name]]
          matches[i[:regex_group_name]] == i[:matches]
        elsif i[:matches_regex] && matches[i[:regex_group_name]]
          matches[i[:regex_group_name]] =~ Regexp.new(i[:matches_regex])
        else
          false
        end
      end
    end

    def matches
      @matches ||= if self.class.constants.include?(:VERIFY_PATTERN)
                     tracking_number.match(self.class.const_get(:VERIFY_PATTERN))
                   else
                     []
                   end
    end

    def match_group(name)
      matches[name].gsub(/\s/, '')
    rescue StandardError
      nil
    end

    def find_matching_partner
      partner_info = self.class.const_get(:PARTNERS) || []

      partner_info.each do |partner_data|
        klass = find_tracking_class_by_id(partner_data[:partner_id])

        return false unless klass

        tn = klass.new(tracking_number)

        valid = if partner_data.dig(:validation, :matches_all)
                  tn.valid? && match_all(partner_data.dig(:validation, :matches_all))
                elsif partner_data.dig(:validation, :matches_any)
                  tn.valid? && match_any(partner_data.dig(:validation, :matches_any))
                else
                  tn.valid?
                end

        next unless valid

        @partner = tn
        @partner_data = partner_data
        break
      end

      return @partner
    end

    def find_tracking_class_by_id(id)
      return unless id

      TrackingNumber::TYPES.detect do |type|
        type.const_get('ID') == id
      end
    end
  end
end
