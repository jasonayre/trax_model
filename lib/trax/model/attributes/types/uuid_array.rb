module Trax
  module Model
    module Attributes
      module Types
        class UuidArray < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize

            attribute_klass = if options.key?(:extends)
              _klass_prototype = options[:extends].is_a?(::String) ? options[:extends].safe_constantize : options[:extends]
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.default_value_for(attribute_name) { attribute_klass.new }
            klass.attribute(attribute_name, TypeCaster.new(target_klass: attribute_klass))
          end

          class Value < ::Trax::Model::UUIDArray
            include ::Trax::Model::ExtensionsFor::Enumerable

            def self.type
              :uuid_array
            end
          end

          class TypeCaster < ::ActiveModel::Type::Value
            include ::ActiveModel::Type::Helpers::Mutable

            def initialize(*args, target_klass:, **options)
              super(*args, **options)

              @target_klass = target_klass
            end

            def type
              :uuid_array
            end

            def cast(value)
              case value.class.name
              when "Array"
                @target_klass.new(*value)
              when @target_klass.name
                value
              else
                @target_klass.new
              end
            end

            def deserialize(value)
              value.present? ? cast(::JSON.parse(value)) : value
            end

            def serialize(value)
              value.try(:to_json)
            end
          end
        end
      end
    end
  end
end
