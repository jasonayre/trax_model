require 'ostruct'

module Trax
  module Model
    module JsonAttributes
      include ::Trax::Model::Mixin

      included do
        class_attribute :json_attribute_fields

        self.json_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new
      end

      module ClassMethods
        def json_attribute(attribute_name, &block)
          attributes_klass_name = "#{attribute_name}_attributes".classify
          attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::JsonAttribute))
          attributes_klass.instance_eval(&block)

          attribute(attribute_name, ::Trax::Model::JsonAttributeType.new(target_klass: attributes_klass))

          self.json_attribute_fields[attribute_name] = attributes_klass
          self.default_value_for(attribute_name) { {} }
          self.validates(attribute_name, :json_attribute => true)
        end
      end
    end
  end
end
