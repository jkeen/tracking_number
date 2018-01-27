module TrackingNumber
  class Info
    def initialize(info_hash = {})
      # puts "code = #{self.code}"
      # puts "name = #{self.name}"
      info_hash.keys.each do |key|
        self.instance_variable_set("@#{key}", info_hash[key])
        self.class_eval { attr_accessor key }
      end
    end

    def to_s
      @name
    end
  end
end
