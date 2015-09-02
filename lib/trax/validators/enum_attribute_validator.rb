class EnumAttributeValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    enum_attribute = object.class.fields_module[attribute]

    unless value.is_a?(enum_attribute) && enum_attribute === value
      binding.pry
      object.errors[attribute] = "#{value} is not an allowed value"
    end
  end
end
