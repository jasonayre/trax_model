require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Json < ::Trax::Model::Attributes::Type
          class Attribute < ::Hashie::Dash
            include Hashie::Extensions::IgnoreUndeclared
            include ActiveModel::Validations

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

          module Mixin
            def self.mixin_registry_key; :json_attributes end;

            include ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin

            included do
              class_attribute :json_attribute_fields

              self.json_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new
            end

            module ClassMethods
              def json_attribute(attribute_name, **options, &block)
                attributes_klass_name = "#{attribute_name}_attributes".classify
                attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:json]::Attribute))
                attributes_klass.instance_eval(&block)

                attribute(attribute_name, ::Trax::Model::Attributes[:json]::TypeCaster.new(target_klass: attributes_klass))
                self.json_attribute_fields[attribute_name] = attributes_klass

                self.default_value_for(attribute_name) { {} }
                self.validates(attribute_name, :json_attribute => true)
              end
            end
          end
        end
      end
    end
  end
end
