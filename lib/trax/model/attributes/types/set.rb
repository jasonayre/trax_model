require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Set < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:extend)
              _klass_prototype = options[:extend].is_a?(::String) ? options[:extend].safe_constantize : options[:extend]
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.default_value_for(attribute_name) { [] }
            # define_model_scopes(klass, attribute_klass)
          end

          # def self.define_scopes_for_array(model, attribute_klass)
          #   return unless has_active_record_ancestry?(property_klass)
          #
          #   model_class = model_class_for_property(property_klass)
          #   field_name = property_klass.parent_definition.name.demodulize.underscore
          #   attribute_name = property_klass.name.demodulize.underscore
          #   scope_name = as || :"by_#{field_name}_#{attribute_name}"
          #
          #   model_class.scope(scope_name, lambda{ |*_scope_values|
          #     _scope_values.flat_compact_uniq!
          #     model_class.where("#{field_name} -> '#{attribute_name}' ?| array[:values]", :values => _scope_values)
          #   })
          # end

          class Value < ::Trax::Model::Attributes::Value
            include ::Trax::Model::EnumerableExtensions

            def initialize(*args)
              @value = ::Set.new(*args)
            end
          end

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type
              :set
            end

            def type_cast_from_user(value)
              case value.class.name
              when "Array"
                @target_klass.new(value)
              when @target_klass.name
                @target_klass
              else
                @target_klass.new
              end
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(::JSON.parse(value)) : value
            end

            def type_cast_for_database(value)
              value.try(:to_json)
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Set::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Set::TypeCaster
        end
      end
    end
  end
end
