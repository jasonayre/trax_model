require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Boolean < ::Trax::Model::Attributes::Type
          class Attribute < ::Trax::Model::Attributes::Attribute
            self.type = :boolean
          end

          class TypeCaster < ActiveRecord::Type::Boolean
          end

          module Mixin
            extend ::ActiveSupport::Concern

            include ::Trax::Model::Attributes::Mixin

            module ClassMethods
              def boolean_attribute(attribute_name, **options, &block)
                attributes_klass = fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:boolean]::Attribute))
                # attributes_klass.instance_eval(&block) if block_given?

                attribute(attribute_name, ::Trax::Model::Attributes[:boolean]::TypeCaster.new)

                self.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
              end
              alias :boolean :boolean_attribute
            end
          end
        end
      end
    end
  end
end
