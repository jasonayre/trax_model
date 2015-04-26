require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          class TypeCaster < ActiveRecord::Type::Integer; end;

          module Mixin
            def self.mixin_registry_key; :enum_attributes end;

            extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin
            include ::Trax::Model::Enum

            module ClassMethods
              def enum_attribute(attribute_name, values:, **options, &block)
                attribute(attribute_name, ::Trax::Model::Attributes[:enum]::TypeCaster.new)

                as_enum(attribute_name, values, **options)
              end
            end
          end
        end
      end
    end
  end
end
