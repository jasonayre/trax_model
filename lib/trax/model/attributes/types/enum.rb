module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          #note: we dont validate enum attribute value because typecaster will turn it into nil which we allow
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize

            attribute_klass = if options.key?(:extends)
              _klass_prototype = options[:extends].is_a?(::String) ? options[:extends].safe_constantize : options[:extends]
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, ::Trax::Core::Types::Enum, :parent_definition => klass, &block)
            end

            attribute_klass.include(::Trax::Model::ExtensionsFor::Enum)

            klass.attribute(attribute_name, ::Trax::Model::Attributes::Types::Enum::TypeCaster.new(target_klass: attribute_klass))

            if options[:default]
              if options[:default].is_a?(Proc)
                klass.default_value_for(attribute_name, &options[:default])
              else
                klass.default_value_for(attribute_name, options[:default])
              end
            end

            define_scopes(klass, attribute_name, attribute_klass) unless options.key?(:define_scopes) && !options[:define_scopes]
          end

          def self.define_scopes(klass, attribute_name, attribute_klass)
            klass.class_eval do
              scope_method_name = :"by_#{attribute_name}"
              scope_not_method_name = :"by_#{attribute_name}_not"

              scope scope_method_name, lambda { |*values|
                values.flat_compact_uniq!
                where(attribute_name => attribute_klass.select_values(*values))
              }
              scope scope_not_method_name, lambda { |*values|
                values.flat_compact_uniq!
                where.not(attribute_name => attribute_klass.select_values(*values))
              }
            end
          end

          class TypeCaster < ::ActiveModel::Type::Value
            include ::ActiveModel::Type::Helpers::Mutable

            def type; :enum end;

            def initialize(*args, target_klass:, **options)
              super(*args, **options)

              @target_klass = target_klass
            end

            def cast(value)
              @target_klass.new(value)
            end

            def deserialize(value)
              @target_klass === value ? cast(value) : nil
            end

            def serialize(value)
              return if value.nil?

              value.try(:to_i) { @target_klass.new(value).to_i }
            end
          end
        end
      end
    end
  end
end
