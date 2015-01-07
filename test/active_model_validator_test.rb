require 'test_helper'

class TrackingNumberValidatorTest < Minitest::Test
  class Validatable
    include ActiveModel::Validations
    attr_accessor :tracking_number
    ERROR_MESSAGE = "must be valid, or 'magic' to prevent inclusion in confirmation email"
    validates :tracking_number, :presence => true,
              :tracking_number => {
                :exception => 'magic',
                :except => 'witchcraft',
                :message => ERROR_MESSAGE
              }
  end
  def test_valid_numbers
    %w(magic witchcraft 790535312317).each do |valid_tracking_number|
      obj = Validatable.new
      obj.tracking_number = valid_tracking_number
      assert obj.valid?, "should allow tracking_number #{valid_tracking_number}"
    end
  end
  def test_invalid_numbers
    %w(wrong 1234).each do |invalid_tracking_number|
      obj = Validatable.new
      obj.tracking_number = invalid_tracking_number
      assert !obj.valid?
      assert_equal obj.errors[:tracking_number], [Validatable::ERROR_MESSAGE]
    end
  end
end
