require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)

            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name.to_s}".camelize

            attribute_klass = (options.key?(:class_name) ? options[:class_name].constantize : ::Trax::ClassWithAttributes.new(
              ::Enum,
              :name => klass_name,
              :model_class => klass,
              &block
            ))

            # binding.pry
            # attribute_klass_definition = (options.key?(:class_name) ? options[:class_name].constantize : ::Class.new(::Enum, &block))
            # attribute_klass = klass.fields_module.const_set(attribute_name.to_s.camelize, attribute_klass_definition)

            klass.attribute(attribute_name, ::Trax::Model::Attributes::Types::Enum::TypeCaster.new(target_klass: attribute_klass))

            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)

            define_scopes(klass, attribute_name, attribute_klass)
          end

          def self.define_scopes(klass, attribute_name, attribute_klass)
            klass.class_eval do
              scope_method_name = :"by_#{attribute_name}"
              scope_not_method_name = :"by_#{attribute_name}_not"

              # binding.pry

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

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def type; :enum end;

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type_cast_from_user(value)
              @target_klass === value ? @target_klass.new(value) : nil
            end

            def type_cast_from_database(value)
              return if value.nil?

              value.present? ? @target_klass.new(value.to_i) : value
            end

            def type_cast_for_database(value)
              return if value.nil?

              value.try(:to_i) { @target_klass.new(value).to_i }
            end

            def changed_in_place?(raw_old_value, new_value)
              raw_old_value.try(:to_i) != type_cast_for_database(new_value)
            end
          end
        end
      end
    end
  end
end
