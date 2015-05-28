require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class String < ::Trax::Model::Attributes::Type
          class Value < ::Trax::Model::Attributes::Value
            def self.type; :string end;

            def initialize(val)
              @val = val
            end

            def __getobj__
              @val
            end
          end

          class TypeCaster < ActiveRecord::Type::String
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end
          end

          module Mixin
            extend ::ActiveSupport::Concern

            include ::Trax::Model::Attributes::Mixin

            module ClassMethods
              def string_attribute(attribute_name, **options, &block)
                attributes_klass = fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:string]::Value))
                attributes_klass.instance_eval(&block) if block_given?

                attribute(attribute_name, ::Trax::Model::Attributes[:string]::TypeCaster.new(target_klass: attributes_klass))

                self.default_value_for(attribute_name) { false }
              end
              alias :string :string_attribute
            end
          end
        end
      end
    end
  end
end
