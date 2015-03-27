class JsonAttributeValidator < ActiveModel::EachValidator
  #not sure if this will be neccessary or how to best handle this yet
  #i suppose though it should loop through the fields and catch any errors, and bubble them up to errors
  def validate_each(object, attribute, value)
    json_attribute = object.class.json_attribute_fields[attribute]
    expected_json_attribute_keys = json_attribute.new.to_hash.keys

    object.errors[attribute] << "Invalid Field Structure" unless value.keys.all?{ expected_json_attribute_keys.include?(attribute) }
  end
end