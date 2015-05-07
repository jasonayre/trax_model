require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class UuidArray < ::Trax::Model::Attributes::Type
          class Value < ::Trax::Model::Attributes::Value
            def initialize(*args)
              @array = ::Trax::Model::UUIDArray.new(*args)
            end

            def __getobj__
              @array
            end

            def inspect
              @array.to_a.flatten.inspect
            end
          end

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type
              :uuid_array
            end

            def type_cast_from_user(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value) || @target_klass.new
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(*value) : @target_klass.new(nil)
            end

            def type_cast_for_database(value)
              if value.present?
                value.to_json
              else
                nil
              end
            end
          end

          module Mixin
            def self.mixin_registry_key; :uuid_array_attributes end;

            extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin

            module ClassMethods
              def uuid_array_attribute(attribute_name, **options, &block)
                attributes_klass_name = "#{attribute_name}_attributes".classify
                attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:uuid_array]::Value))
                attributes_klass.instance_eval(&block) if block_given?

                attributes_klass.element_class = options[:of] if options.has_key?(:of)

                trax_attribute_fields[:uuid_array] ||= {}
                trax_attribute_fields[:uuid_array][attribute_name] = attributes_klass

                if options.has_key?(:default)
                  self.default_value_for(attribute_name, options[:default])
                else
                  []
                end

                attribute(attribute_name, ::Trax::Model::Attributes[:uuid_array]::TypeCaster.new(target_klass: attributes_klass))
              end
            end
          end
        end
      end
    end
  end
end
