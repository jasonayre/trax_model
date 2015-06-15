class FutureValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors[attribute] << 'Must be in future' if value && (value < ::DateTime.now)
  end
end
