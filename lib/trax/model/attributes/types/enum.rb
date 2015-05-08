require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          class TypeCaster < ActiveRecord::Type::Integer
            def type; :enum end;
          end

          module Mixin
            def self.mixin_registry_key; :enum_attributes end;

            extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin
            include ::Trax::Model::Enum

            module ClassMethods
              def enum_attribute(attribute_name, values:, **options, &block)
                options.delete(:validates) if options.key?(:validates)

                as_enum(attribute_name, values, **options)

                define_method("#{attribute_name}=") do |val|
                  current_value = read_attribute(attribute_name)
                  old_value = values[current_value] if current_value
                  set_attribute_was(attribute_name, old_value) if old_value && old_value != val

                  super(val)
                end
              end
            end
          end
        end
      end
    end
  end
end
