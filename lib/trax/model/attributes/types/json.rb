require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Json < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            attributes_klass = klass.fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(value_klass))
            attributes_klass.instance_eval(&block)
            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attributes_klass))
            klass.validates(attribute_name, :json_attribute => true) unless options.key?(:validate) && !options[:validate]
            klass.default_value_for(attribute_name) { {} }
          end

          class Value < ::Trax::Model::Struct
            def self.type; :json end;

            def self.permitted_keys
              @permitted_keys ||= properties.map(&:to_sym)
            end

            def inspect
              self.to_hash.inspect
            end
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
              value.present? ? value.to_hash.to_json : nil
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Json::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Json::TypeCaster
        end
      end
    end
  end
end
