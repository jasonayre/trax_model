module Trax
  module Model
    module Attributes
      class Type
        def self.inherited(subklass)
          ::Trax::Model::Attributes.register_attribute_type(subklass)
        end
      end
    end
  end
end
