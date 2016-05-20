# validates each json property and bubbles up any errors
# also throws a generic can not be blank error, in the event
# that a hash is not provided
class JsonAttributeValidator < ActiveModel::EachValidator
  #todo: hack, this validates each block gets called x times per struct where
  #x = number of attributes on the struct. Not sure why,
  #so for now just call uniq! on the errors
  def validate_each(object, attribute, value)
    json_attribute = object.class.fields_module[attribute]
    value = json_attribute.new(value || {}) unless value.is_a?(json_attribute)

    value.instance_variable_set("@record", object)

    unless value.is_a?(json_attribute) && value.valid?
      if value.is_a?(json_attribute)
        value.errors.messages.each_pair do |k,v|
          v = v.flatten.join(", ") if v.is_a?(Array)
          object.errors.add("#{attribute}.#{k}", v)
          object.errors["#{attribute}.#{k}"] << v
          object.errors["#{attribute}.#{k}"].uniq!
        end
      else
        object.errors[attribute] << "can not be blank"
      end
    end
  end
end
