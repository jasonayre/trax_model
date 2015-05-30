require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class String < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            attributes_klass = klass.fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(value_klass))
            attributes_klass.instance_eval(&block) if block_given?
            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attributes_klass))
            # klass.validates(attribute_name, :json_attribute => true) unless options.key?(:validate) && !options[:validate]
            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class Value < ::Trax::Model::Attributes::Value
            def self.type; :string end;
          end

          class TypeCaster < ActiveRecord::Type::String
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::String::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::String::TypeCaster
        end
      end
    end
  end
end
