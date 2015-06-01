require 'hashie/extensions/ignore_undeclared'
#totally not working atm :), dont use me!
module Trax
  module Model
    module Attributes
      module Types
        class Array < ::Trax::Model::Attributes::Type
          def self.define_attribute(source_klass, attribute_name, **options, &block)
            klass.fields_module.const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:array]::Value))
          end

          class Attribute < ::Trax::Model::Attributes::Attribute
            self.type = :array
          end

          class Value < ::Trax::Model::Attributes::Value
            class_attribute :element_class
            include ::Enumerable

            def initialize(*args)
              @array = super(*args)
              @array.map!{ |ele| self.class.element_class.new(ele) } if self.class.element_class && @array.any?
            end

            def __getobj__
              @array
            end

            def <<(val)
              if self.class.element_class && val.class == self.class.element_class
                super(val)
              else
                super(self.class.element_class.new(val))
              end
            end

            def each(&block)
              yield __getobj__.each(&block)
            end
          end

          class TypeCaster < ActiveRecord::Type::Value
            include ::ActiveRecord::Type::Mutable

            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type
              :array
            end

            def type_cast_from_user(value)
              value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(JSON.parse(value)) : value
            end

            def type_cast_for_database(value)
              if value.present?
                value.map{ |element| element.try(:to_json) }
              else
                nil
              end
            end
          end

          # module Mixin
          #   def self.mixin_registry_key; :array_attributes end;
          #
          #   extend ::Trax::Model::Mixin
          #   include ::Trax::Model::Attributes::Mixin
          #
          #   module ClassMethods
          #     def array_attribute(attribute_name, **options, &block)
          #       attributes_klass_name = "fields/#{attribute_name}".camelize
          #       attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:array]::Value))
          #       attributes_klass.instance_eval(&block)
          #
          #       attributes_klass.element_class = options[:of] if options.has_key?(:of)
          #
          #       attribute(attribute_name, ::Trax::Model::Attributes[:array]::TypeCaster.new(target_klass: attributes_klass))
          #     end
          #   end
          # end
        end
      end
    end
  end
end
