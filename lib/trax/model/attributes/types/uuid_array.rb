require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class UuidArray < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:class_name)
              options[:class_name].constantize
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            attribute_klass.element_class = options[:of] if options.has_key?(:of)
            options.has_key?(:default) ? self.default_value_for(attribute_name, options[:default]) : []
            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
          end

          class Attribute < ::Trax::Model::Attributes::Attribute
            self.type = :uuid_array
          end

          class Value < ::Trax::Model::Attributes::Value
            def initialize(*args)
              @array = ::Trax::Model::UUIDArray.new(*args)
            end

            def __getobj__
              @array
            end

            def inspect
              @array.to_a.flatten.inspect
            end
          end

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type
              :uuid_array
            end

            def type_cast_from_user(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value) || @target_klass.new
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(*value) : @target_klass.new(nil)
            end

            def type_cast_for_database(value)
              if value.present?
                value.to_json
              else
                nil
              end
            end
          end
        end
      end
    end
  end
end
