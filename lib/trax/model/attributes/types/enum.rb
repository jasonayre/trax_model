require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            attributes_klass = klass.fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Enum))
            attributes_klass.instance_eval(&block)

            klass.class_eval do
              define_method("#{attribute_name}=") do |val|
                current_value = read_attribute(attribute_name)
                old_value = attributes_klass[current_value] if current_value
                set_attribute_was(attribute_name, old_value) if old_value && old_value != val

                write_attribute(attribute_name, val)
              end

              define_method(attribute_name) do
                # binding.pry
                attributes_klass[read_attribute(attribute_name)]
              end
            end

            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class TypeCaster < ActiveRecord::Type::Integer
            def type; :enum end;
          end

          # module Mixin
          #   def self.mixin_registry_key; :enum_attributes end;
          #
          #   extend ::Trax::Model::Mixin
          #   include ::Trax::Model::Attributes::Mixin
          #   include ::Trax::Model::Enum
          #
          #   module ClassMethods
          #     def enum_attribute(attribute_name, values:, **options, &block)
          #       options.delete(:validates) if options.key?(:validates)
          #
          #       as_enum(attribute_name, values, **options)
          #
          #       define_method("#{attribute_name}=") do |val|
          #         current_value = read_attribute(attribute_name)
          #         old_value = values[current_value] if current_value
          #         set_attribute_was(attribute_name, old_value) if old_value && old_value != val
          #
          #         super(val)
          #       end
          #     end
          #   end
          # end
        end
      end
    end
  end
end
