module Trax
  module Model
    module Attributes
      module Types
        class Set < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:extends)
              _klass_prototype = options[:extends].is_a?(::String) ? options[:extends].safe_constantize : options[:extends]
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            attribute_klass.contains_instances_of(options[:contains_instances_of]) if options[:contains_instances_of]

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.default_value_for(attribute_name) { attribute_klass.new }
          end

          class Value < ::Trax::Core::Types::Set
            include ::Trax::Model::ExtensionsFor::Set
          end

          class TypeCaster < ::ActiveModel::Type::Value
            include ::ActiveModel::Type::Helpers::Mutable

            def initialize(*args, target_klass:, **options)
              super(*args, **options)

              @target_klass = target_klass
            end

            def type; :set end

            def cast(value)
              case value.class.name
              when "Array", "Set"
                @target_klass.new(value)
              when @target_klass.name
                value
              else
                @target_klass.new
              end
            end

            def serialize(value)
              value.try(:to_json)
            end

            def deserialize(value)
              value.present? ? @target_klass.new(::JSON.parse(value)) : value
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Set::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Set::TypeCaster
        end
      end
    end
  end
end
