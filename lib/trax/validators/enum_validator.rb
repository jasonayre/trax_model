class EnumValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    enum_attribute = object.class.fields_module[attribute]

    unless value.is_a?(enum_attribute) && enum_attribute === value
      if value.is_a?(enum_attribute)
        value.errors.messages.each_pair do |k,v|
          v = v.join(", ") if v.is_a?(Array)
          object.errors["#{attribute}.#{k}"] = v
        end
      else
        object.errors[attribute] = "#{value} is not an allowed value"
      end
    end
  end
end
