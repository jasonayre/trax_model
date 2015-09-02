require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class String < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name.to_s}".camelize
            attribute_klass = if options.key?(:class_name)
              options[:class_name].constantize
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.validates(attribute_name, options[:validates]) if options.key?(:validates)
            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class Value < ::Trax::Model::Attributes::Value
            def self.type; :string end;
          end

          class TypeCaster < ActiveRecord::Type::String
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::String::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::String::TypeCaster
        end
      end
    end
  end
end
