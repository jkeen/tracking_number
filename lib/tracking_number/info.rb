module TrackingNumber
  class Info
    def initialize(info_hash = {})
      info_hash.keys.each do |key|
        self.instance_variable_set("@#{key}", info_hash[key])
        self.class_eval { attr_accessor key }
      end

      if info_hash.keys.size == 1
        @default = info_hash[info_hash.keys.first]
      end
    end

    def method_missing(name, *args)
      self.instance_variable_get("@#{name}")
    end

    def to_s
      @default || @name
    end

    def to_json

    end
  end
end
