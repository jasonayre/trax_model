require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Struct < ::Trax::Model::Attributes::Type
          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:extends)
              _klass_prototype = options[:extends].is_a?(::String) ? options[:extends].safe_constantize : options[:extends]
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass.include(::Trax::Model::ExtensionsFor::Struct)
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.validates(attribute_name, :json_attribute => true) unless options.key?(:validate) && !options[:validate]

            if options[:default] && options[:default].is_a?(Proc)
              klass.default_value_for(attribute_name, &options[:default])
            else
              klass.default_value_for(attribute_name, options[:default] || {})
            end

            define_model_accessors(klass, attribute_name, attribute_klass, options[:model_accessors]) if options.key?(:model_accessors) && options[:model_accessors]
          end

          class Value < ::Trax::Core::Types::Struct
            include ::Trax::Model::ExtensionsFor::Struct


          end

          class TypeCaster < ::ActiveModel::Type::Value
            include ::ActiveModel::Type::Helpers::Mutable

            def initialize(*args, target_klass:, **options)
              super(*args, **options)

              @target_klass = target_klass
            end

            def type
              :struct
            end

            def cast(value)
              value.is_a?(@target_klass) ? value : @target_klass.new(value || {})
            end

            def deserialize(value)
              return value unless value.is_a?(::String)
              value.present? ? @target_klass.new(::JSON.parse(value)) : value
            end

            def serialize(value)
              value.present? ? value.to_serializable_hash.to_json : {}.to_json
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Struct::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Struct::TypeCaster

          private

          def self.define_model_accessors(model, attribute_name, struct_attribute, option_value)
            properties_to_define = if [ true ].include?(option_value)
                                     struct_attribute.properties.to_a
                                   elsif option_value.is_a?(Hash) && option_value.has_key?(:only)
                                     struct_attribute.properties.to_a & option_value[:only]
                                   elsif option_value.is_a?(Hash) && option_value.has_key?(:except)
                                     struct_attribute.properties.to_a - option_value[:except]
                                   elsif option_value.is_a?(Array)
                                     struct_attribute.properties.to_a & option_value
                                   else
                                     raise Trax::Model::Errors::InvalidOption.new(
                                       :option => :model_accessors,
                                       :valid_choices => ["true", "array of properties", "hash with :only or :except keys"]
                                     )
                                   end

            properties_to_define.each do |_property|
              getter_method, setter_method = _property.to_sym, :"#{_property}="

              model.__send__(:define_method, setter_method) do |val|
                self[attribute_name] = {} unless self[attribute_name]
                self.__send__(attribute_name).__send__(setter_method, val)
              end

              model.delegate(getter_method, :to => attribute_name)
            end
          end
        end
      end
    end
  end
end
