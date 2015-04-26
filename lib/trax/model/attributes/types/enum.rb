require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          # class Value < SimpleDelegator
          #
          #   include ActiveModel::Validations
          #
          #   def self.permitted_keys
          #     @permitted_keys ||= properties.map(&:to_sym)
          #   end
          #
          #   def inspect
          #     self.to_hash.inspect
          #   end
          # end

          class TypeCaster < ActiveRecord::Type::Integer
          end

          module Mixin
            def self.mixin_registry_key; :enum_attributes end;

            include ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin

            included do
              class_attribute :enum_attribute_fields

              self.enum_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new
            end

            module ClassMethods
              def enum_attribute(attribute_name, values:, **options, &block)
                attributes_klass_name = "#{attribute_name}_attributes".classify
                # attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:enum]::Value))
                attributes_klass.instance_eval(&block) if block_given?

                attribute(attribute_name, ::Trax::Model::Attributes[:enum]::TypeCaster.new)

                # binding.pry
                as_enum(attribute_name, values, **options)


                # self.json_attribute_fields[attribute_name] = attributes_klass





                # self.default_value_for(attribute_name) { {} }
                # self.validates(attribute_name, :json_attribute => true)
              end
            end
          end
        end
      end
    end
  end
end
