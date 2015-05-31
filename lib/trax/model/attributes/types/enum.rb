require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            attribute_klass = klass.fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Enum, &block))
            klass.attribute(attribute_name, ::Trax::Model::Attributes::Types::Enum::TypeCaster.new(target_klass: attribute_klass))

            klass.class_eval do
              define_method("#{attribute_name}=") do |val|
                current_value = read_attribute(attribute_name)
                # binding.pry
                old_value = attribute_klass[current_value] if current_value
                set_attribute_was(attribute_name, old_value) if old_value && old_value != val

                new_value = attribute_klass[val]

                write_attribute(attribute_name, new_value.nil? ? nil : new_value)
              end

              define_method(attribute_name) do
                value = read_attribute(attribute_name)
                value.is_a?(attribute_klass) ? value : attribute_klass[value]
              end
            end

            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)

            define_scopes(klass, attribute_name, attribute_klass)
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

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def type; :integer end;

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type_cast_from_user(value)
              @target_klass.new(value.to_i)
            end

            def type_cast_from_database(value)
              return if value.nil?

              value.present? ? @target_klass.new(value.to_i) : value
            end

            def type_cast_for_database(value)
              return if value.nil?
              value.to_i
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
