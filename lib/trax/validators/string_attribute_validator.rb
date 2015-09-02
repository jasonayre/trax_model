# validates each json property and bubbles up any errors
# also throws a generic can not be blank error, in the event
# that a hash is not provided
class StringAttributeValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    string_attribute = value.class

    unless value.valid?
      if value.is_a?(string_attribute)
        value.errors.messages.each_pair do |k,v|
          v.flatten.join(", ") if v.is_a?(Array)
          object.errors.add("#{attribute}.#{k}", v)
        end
      end
    end
  end
end
