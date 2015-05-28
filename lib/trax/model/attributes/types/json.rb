require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Json < ::Trax::Model::Attributes::Type
          class Value < ::Trax::Model::Struct
            def self.symbolic_name; name.demodulize.underscore.to_sym; end
            def self.type; :json end;

            def self.permitted_keys
              @permitted_keys ||= properties.map(&:to_sym)
            end

            def to_hash

              self.class.fields_module.values.each_with_object({}) do |field, result|
                case field.type
                when :enum
                  result[field.name.symbolize] = self.try(field.name.symbolize)
                when :json
                  result[field.name.symbolize] = self.try(field.name.symbolize)
                when :json
                  result[field.name.symbolize] = self.try(field.name.symbolize)
                else
                  result[field.name.symbolize] = self.try(field.name.symbolize)
                end

                result
              end
            end

            def inspect
              result = self.class.fields_module.values.each_with_object({}) do |field, result|

                case field.type
                when :enum
                  result[field.name.symbolize] = self.try(field.name.symbolize).to_s
                when :json
                  # binding.pry
                  result[field.name.symbolize] = self.try(field.name.symbolize).to_hash
                when :struct
                  result[field.name.symbolize] = self.try(field.name.symbolize).to_hash
                when :boolean
                  result[field.name.symbolize] = self[field.name.symbolize] if(::Is.truthy?(self[field.name.symbolize]))
                else
                  result[field.name.symbolize] = self.try(field.name.symbolize)
                end

                binding.pry

                result
              end

              "#{result}"
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

          module Mixin
            extend ::ActiveSupport::Concern
            # def self.mixin_registry_key; :json_attributes end;
            #
            # extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin

            included do
              class_attribute :json_attribute_fields

              self.json_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new
            end

            module ClassMethods
              def json_attribute(attribute_name, **options, &block)

                # attributes_klass_name = "#{attribute_name}_attributes".classify
                # attributes_klass =
                # attributes_klass.instance_eval(&block)

                attributes_klass = fields_module.const_set(attribute_name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:json]::Value))
                attributes_klass.instance_eval(&block)

                # binding.pry
                # fields_module.const_set(attribute_name, )
                # attributes_klass = fields_module.const_set(attribute_name.to_s.camelize,)


                # trax_attribute_fields[:json] ||= {}
                # trax_attribute_fields[:json][attribute_name] = attributes_klass

                attribute(attribute_name, ::Trax::Model::Attributes[:json]::TypeCaster.new(target_klass: attributes_klass))

                self.default_value_for(attribute_name) { {} }
                self.validates(attribute_name, :json_attribute => true) unless options.key?(:validate) && !options[:validate]

                # return attributes_klass
              end
            end
          end
        end
      end
    end
  end
end
