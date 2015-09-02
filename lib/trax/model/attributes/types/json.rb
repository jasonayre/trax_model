require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Json < ::Trax::Model::Attributes::Type
          module ValueExtensions
            extend ::ActiveSupport::Concern

            def inspect
              self.to_hash.inspect
            end

            def to_json
              self.to_hash.to_json
            end

            module ClassMethods
              def type; :struct end;

              def permitted_keys
                @permitted_keys ||= properties.map(&:to_sym)
              end
            end
          end

          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name.to_s}".camelize
            attribute_klass = if options.key?(:class_name)
              _klass = options[:class_name].constantize
              _klass.include(ValueExtensions)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.validates(attribute_name, :json_attribute => true) unless options.key?(:validates) && !options[:validates]
            klass.default_value_for(attribute_name) { {} }
          end

          class Value < ::Trax::Model::Struct
            include ValueExtensions
          end

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type
              :json
            end

            def type_cast_from_user(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(JSON.parse(value)) : value
            end

            def type_cast_for_database(value)
              value.present? ? value.to_serializable_hash.to_json : nil
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Json::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Json::TypeCaster
        end
      end
    end
  end
end
