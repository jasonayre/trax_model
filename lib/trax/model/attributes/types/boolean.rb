module Trax
  module Model
    module Attributes
      module Types
        class Boolean < ::Trax::Model::Attributes::Type
          #this will by default validate boolean values
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:class_name)
              options[:class_name].constantize
            else
              ::Trax::Core::NamedClass.new(klass_name, ::Trax::Model::Attributes[:boolean]::Attribute, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, ::Trax::Model::Attributes::Types::Boolean::TypeCaster.new)
            klass.validates(attribute_name, :boolean => true) unless options.key?(:validate) && !options[:validate]
            klass.default_value_for(attribute_name) { options[:default] } if options.key?(:default)
          end

          class Attribute < ::Trax::Model::Attributes::Attribute
            include ::Trax::Model::ExtensionsFor::Boolean
            self.type = :boolean

            def self.to_schema
              ::Trax::Core::Definition.new({
                :name => attribute_name,
                :type => type.to_s,
                :source => name,
                :values => values
              })
            end

            private

            def self.attribute_name
              name.demodulize.underscore
            end

            def self.values
              [ true, false ]
            end
          end

          class TypeCaster < ::ActiveModel::Type::Boolean
          end
        end
      end
    end
  end
end
