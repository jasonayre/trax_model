require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          class Value < ::Trax::Model::Attributes::Value
            include ActiveModel::Validations

            class_attribute :values

            def self.value(value_name)
              values << value_name
            end

            def initialize(integer_value)
              puts integer_value
              # binding.pry
              @value = self.class.values.fetch(integer_value, nil)
              puts @value
              @value
            end

            def __getobj__
              @value
            end
          end

          class TypeCaster < ActiveRecord::Type::Integer
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type_cast_from_user(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value)
            end

            def type_cast_from_database(value)
              v = super(value)
              v.present? ? @target_klass.new(v) : v
            end

            def type_cast

            end

            # def type_cast_from_database(value)
            #   @target_klass.new(super(value))
            # end
          end

          module Mixin
            def self.mixin_registry_key; :enum_attributes end;

            extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin
            include ::Trax::Model::Enum

            module ClassMethods
              def enum_attribute(attribute_name, values:, **options, &block)
                attributes_klass_name = "#{attribute_name}_attributes".classify
                attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:enum]::Value))
                attributes_klass.values = values
                attributes_klass.instance_eval(&block) if block_given?

                trax_attribute_fields[:enum] ||= {}
                trax_attribute_fields[:enum][attribute_name] = attributes_klass

                attribute(attribute_name, ::Trax::Model::Attributes[:enum]::TypeCaster.new(target_klass: attributes_klass))

                # attribute(attribute_name, ::Trax::Model::Attributes[:enum]::TypeCaster.new)

                self.validates(attribute_name, :enum => true)

                as_enum(attribute_name, values, **options)
              end
            end
          end
        end
      end
    end
  end
end
