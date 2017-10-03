class TrackingNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    if options[:exception] == value || options[:except] == value
      # magic valid value (an exception that says "not really shipped" or something)
    elsif TrackingNumber.new(value).valid?
      # looks good to me
    else
      record.errors[attribute] << (options[:message] || 'is not a valid tracking number')
    end
  end
end
