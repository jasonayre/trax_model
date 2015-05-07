### Credit to Jason Staten, https://github.com/statianzo
class BooleanValidator < ActiveModel::Validations::InclusionValidator
  def initialize(options)
    options[:in] = [true, false].to_set
    options[:message] = "must be true or false"
    super
  end

  module HelperMethods
    def validates_booleans(*attr_names)
      validates_with(::BooleanValidator, _merge_attributes(attr_names))
    end
  end
end
