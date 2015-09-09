require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Integer < ::Trax::Model::Attributes::Type
          module TypeCasterExtensions
            def attribute_klass=(val)
              @target_klass = val

              self.extend(::ActiveModel::Validations)

              self
            end

            def type_cast_from_user(value)
              value = super(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
            end

            def type_cast_from_database(value)
              value = super(value)
              value.present? ? @target_klass.new(value) : value
            end

            def type_cast_for_database(value)
              value = super(value)
              value.try(:to_i)
            end
          end

          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:class_name)
              options[:class_name].constantize
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            typecaster = typecaster_klass.new
            typecaster.extend(TypeCasterExtensions)
            typecaster.attribute_klass = attribute_klass
            klass.attribute(attribute_name, typecaster)
            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class Value < ::Trax::Model::Attributes::Value
            def self.type; :integer end;
          end

          class TypeCaster < ::ActiveRecord::Type::Integer
          end

          # class TypeCaster < ::ActiveRecord::Type::Integer
          #   def initialize(*args, target_klass:)
          #     super(*args)
          #
          #     @target_klass = target_klass
          #   end
          # end

          # class TypeCaster < ActiveRecord::Type::String
          #   def initialize(*args, target_klass:)
          #     super(*args)
          #
          #     @target_klass = target_klass
          #   end
          #
          #   def type_cast_from_user(value)
          #     value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
          #   end
          #
          #   def type_cast_from_database(value)
          #     value.present? ? @target_klass.new(value) : value
          #   end
          #
          #   def type_cast_for_database(value)
          #     value.try(:to_s)
          #   end
          # end

          self.value_klass = ::Trax::Model::Attributes::Types::Integer::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Integer::TypeCaster
        end
      end
    end
  end
end
