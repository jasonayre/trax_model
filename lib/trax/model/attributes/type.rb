module Trax
  module Model
    module Attributes
      class Type
        class_attribute :value_klass
        class_attribute :attribute_klass
        class_attribute :typecaster_klass

        def self.inherited(subklass)
          ::Trax::Model::Attributes.register_attribute_type(subklass)
        end
      end
    end
  end
end
