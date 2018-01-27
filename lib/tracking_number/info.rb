module TrackingNumber
  class Info
    def initialize(info_hash = {})
      info_hash.keys.each do |key|
        self.class.send(:attr_accessor, key)
        self.instance_variable_set("@#{key}", info_hash[key])
      end
    end

    def to_s
      @name
    end
  end
end
