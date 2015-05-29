module Trax
  module Model
    module Attributes
      module Errors
        class UnknownAttributeType < ::Trax::Core::Errors::Base
          argument :type, :required => true

          message {
            "#{type} is an unknown trax model attribute type"
          }
        end

        class DefineAttributeMethodNotDefined < ::Trax::Core::Errors::Base
          argument :type, :required => true

          message {
            "#{type} must define a define_attribute method"
          }
        end
      end
    end
  end
end
