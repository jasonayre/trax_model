class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def validate_each(record, attribute, value)
    unless (value =~ EMAIL_REGEX).present?
      record.errors[attribute] = (options[:message] || "is not a valid email")
    end
    record
  end
end
