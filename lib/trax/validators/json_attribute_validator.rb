class JsonAttributeValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    json_attribute = object.class.json_attribute_fields[attribute]

    unless value.valid?
      value.errors.messages.each_pair do |k,v|
        object.errors["#{attribute}.#{k}"] << v
      end
    end
  end
end
