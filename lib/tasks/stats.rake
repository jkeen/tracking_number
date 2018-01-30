require 'terminal-table'

def courier_data
  courier_data = Dir.glob(File.join(File.dirname(__FILE__), "../../lib/data/couriers/*.json")).collect do |file|
    JSON.parse(File.read(file)).deep_symbolize_keys!
  end
end

def all_number_groups
  number_groups = []
  courier_data.each do |courier_info|
    courier_info[:tracking_numbers].each do |tracking_info|
      test_number = tracking_info[:test_numbers][:valid].first
      t = TrackingNumber.new(test_number)
      # keys = t.decode.keys.select { |s| ![:serial_number, :check_digit].include?(s) }
      number_groups << t.decode.keys
    end
  end
  groups = number_groups.flatten.uniq.sort
end

def has_key?(tracking_numbers, key)
  tracking_numbers = [tracking_numbers].flatten
  tracking_numbers.first.decode[key]
end

def has_additional_key_info?(tracking_numbers, key)
  tracking_numbers = [tracking_numbers].flatten

  if key == :service_type
    tracking_numbers.any? { |t| t.service_type }
  elsif key == :shipping_container_type
    tracking_numbers.any? { |t| t.package_info }
  elsif key == :destination_zip
    tracking_numbers.any? { |t| t.destination }
  end
end


  desc "show stats for tracking number types"
  task :stats do
    rows = []

    courier_data.each do |courier_info|
      courier_name = courier_info[:name]
      courier_code = courier_info[:courier_code].to_sym

      courier_info[:tracking_numbers].each do |tracking_info|
        tracking_type = tracking_info[:name]

        if tracking_type == "S10"
          country_count = tracking_info[:additional].detect { |r| r[:regex_group_name] == "CountryCode" }[:lookup].size
          tracking_type = "S10 (#{country_count} types)"
        end

        tracking_numbers = tracking_info[:test_numbers][:valid].collect { |n| TrackingNumber.new(n) }

        checksum_status = tracking_numbers.first.valid_checksum? &&

        checksum = tracking_numbers.first.class.const_get(:VALIDATION)[:checksum]
        if checksum
          checksum_status = '✓'
        else
          checksum_status = ''
        end


        status = all_number_groups.collect do |key|
           s = has_key?(tracking_numbers, key) ? '✓' : ''
           s = has_additional_key_info?(tracking_numbers, key) ? '✓+' : s

           s
        end

        rows << [tracking_type, checksum_status, *status]
      end
    end

    additional_headers = all_number_groups.collect { |g|
      if g.length > 10
        g.to_s.split('_').join("_\n")
      else
        g
      end
    }

    table = Terminal::Table.new :title => "Tracking Number Stats [✓ = information present in number, ✓+ = additional information available]", :headings => ['Tracking Number', 'Checksum', *additional_headers], :rows => rows

    puts table
  end
