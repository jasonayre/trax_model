module Trax
  module Model
    module Attributes
      module Types
        class Integer < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:class_name)
              options[:class_name].constantize
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new)
            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class Value < ::Trax::Model::Attributes::Value
            include ::Trax::Model::ExtensionsFor::Numeric
            
            def self.type; :integer end;
          end

          class TypeCaster < ::ActiveRecord::Type::Integer
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Integer::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Integer::TypeCaster
        end
      end
    end
  end
end
