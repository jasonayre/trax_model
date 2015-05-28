require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Boolean < ::Trax::Model::Attributes::Type
          class Value < ::Trax::Model::Attributes::Value
            def self.type; :boolean end;

            def initialize(val)
              @val = val
            end

            def __getobj__
              @val
            end
          end

          class TypeCaster < ActiveRecord::Type::Boolean
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end
          end

          module Mixin
            extend ::ActiveSupport::Concern

            include ::Trax::Model::Attributes::Mixin

            module ClassMethods
              def boolean_attribute(attribute_name, **options, &block)
                attributes_klass = fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:boolean]::Value))
                attributes_klass.instance_eval(&block)

                attribute(attribute_name, ::Trax::Model::Attributes[:boolean]::TypeCaster.new(target_klass: attributes_klass))

                self.default_value_for(attribute_name) { false }
              end
              alias :boolean :boolean_attribute
            end
          end
        end
      end
    end
  end
end
