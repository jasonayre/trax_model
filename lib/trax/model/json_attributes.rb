require 'ostruct'

module Trax
  module Model
    module JsonAttributes
      include ::Trax::Model::Mixin

      included do
        class_attribute :json_attribute_fields

        self.json_attribute_fields = {}
      end

      module ClassMethods
        def json_attribute(attribute_name, &block)
          self.send(:define_method, :"#{attribute_name.to_s}") do
            ivar = :"@#{attribute_name}"
            return instance_variable_get(ivar) if instance_variable_names.include?("@#{attribute_name}")
            wrapped_json = json_attribute_fields[attribute_name].new(super())
            instance_variable_set(ivar, wrapped_json)
            instance_variable_get(ivar)
          end

          attributes_klass_name = "#{attribute_name}_attributes".classify
          attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::JsonAttribute))
          attributes_klass.instance_eval(&block)

          self.json_attribute_fields[attribute_name] = attributes_klass
          self.default_value_for(attribute_name) { attributes_klass.new }
          self.validates(attribute_name, :json_attribute => true)
        end
      end
    end
  end
end
