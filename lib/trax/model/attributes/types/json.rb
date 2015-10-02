require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Json < ::Trax::Model::Attributes::Type
          module ValueExtensions
            extend ::ActiveSupport::Concern

            include ::ActiveModel::Validations

            def inspect
              self.to_hash.inspect
            end

            def to_json
              self.to_hash.to_json
            end

            def to_serializable_hash
              _serializable_hash = to_hash

              self.class.fields_module.enums.keys.each do |attribute_name|
                _serializable_hash[attribute_name] = _serializable_hash[attribute_name].try(:to_i)
              end if self.class.fields_module.enums.keys.any?

              _serializable_hash
            end

            module ClassMethods
              def type; :struct end;

              def permitted_keys
                @permitted_keys ||= properties.map(&:to_sym)
              end

              #this only supports properties 1 level deep, but works beautifully
              #I.E. for this structure
              # define_attributes do
              #   struct :custom_fields do
              #     enum :color, :default => :blue do
              #       define :blue,     1
              #       define :red,      2
              #       define :green,    3
              #     end
              #   end
              # end
              # ::Product.by_custom_fields_color(:blue, :red)
              # will return #{Product color=blue}, #{Product color=red}
              def define_scopes_for_enum(attribute_name, enum_klass)
                return unless has_active_record_ancestry?(enum_klass)

                model_class = model_class_for_property(enum_klass)
                field_name = enum_klass.parent_definition.name.demodulize.underscore
                attribute_name = enum_klass.name.demodulize.underscore
                scope_name = :"by_#{field_name}_#{attribute_name}"
                model_class.scope(scope_name, lambda{ |*_scope_values|
                  _integer_values = enum_klass.select_values(*_scope_values.flat_compact_uniq!)
                  _integer_values.map!(&:to_s)
                  model_class.where("#{field_name} -> '#{attribute_name}' IN(?)", _integer_values)
                })
              end

              def define_where_scopes_for_boolean_property(attribute_name, property_klass)
                return unless has_active_record_ancestry?(property_klass)

                model_class = model_class_for_property(property_klass)
                field_name = property_klass.parent_definition.name.demodulize.underscore
                attribute_name = property_klass.name.demodulize.underscore
                scope_name = :"by_#{field_name}_#{attribute_name}"
                model_class.scope(scope_name, lambda{ |*_scope_values|
                  _scope_values.map!(&:to_s).flat_compact_uniq!
                  model_class.where("#{field_name} -> '#{attribute_name}' IN(?)", _scope_values)
                })
              end

              def define_where_scopes_for_property(attribute_name, property_klass)
                return unless has_active_record_ancestry?(property_klass)

                model_class = model_class_for_property(property_klass)
                field_name = property_klass.parent_definition.name.demodulize.underscore
                attribute_name = property_klass.name.demodulize.underscore
                scope_name = :"by_#{field_name}_#{attribute_name}"

                model_class.scope(scope_name, lambda{ |*_scope_values|
                  _scope_values.map!(&:to_s).flat_compact_uniq!
                  model_class.where("#{field_name} ->> '#{attribute_name}' IN(?)", _scope_values)
                })
              end

              def has_active_record_ancestry?(property_klass)
                return false unless property_klass.respond_to?(:parent_definition)

                result = if property_klass.parent_definition.ancestors.include?(::ActiveRecord::Base)
                  true
                else
                  has_active_record_ancestry?(property_klass.parent_definition)
                end

                result
              end

              def model_class_for_property(property_klass)
                result = if property_klass.parent_definition.ancestors.include?(::ActiveRecord::Base)
                  property_klass.parent_definition
                else
                  model_class_for_property(property_klass.parent_definition)
                end

                result
              end

            end
          end

          def self.define_attribute(klass, attribute_name, **options, &block)
            klass_name = "#{klass.fields_module.name.underscore}/#{attribute_name}".camelize
            attribute_klass = if options.key?(:extend)
              _klass_prototype = options[:extend].constantize
              _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => klass, &block)
              _klass.include(ValueExtensions) unless klass.const_defined?("ValueExtensions")
              _klass
            else
              ::Trax::Core::NamedClass.new(klass_name, Value, :parent_definition => klass, &block)
            end

            klass.attribute(attribute_name, typecaster_klass.new(target_klass: attribute_klass))
            klass.validates(attribute_name, :json_attribute => true) unless options.key?(:validate) && !options[:validate]
            klass.default_value_for(attribute_name) { {} }
            define_model_accessors(klass, attribute_name, attribute_klass, options[:model_accessors]) if options.key?(:model_accessors) && options[:model_accessors]
            define_model_scopes(klass, attribute_name, attribute_klass, options[:model_scopes]) if options.key?(:model_scopes) && options[:model_scopes]
          end

          class Value < ::Trax::Model::Struct
            include ValueExtensions
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
              value.is_a?(@target_klass) ? value : @target_klass.new(value || {})
            end

            def type_cast_from_database(value)
              value.present? ? @target_klass.new(::JSON.parse(value)) : value
            end

            def type_cast_for_database(value)
              value.present? ? value.to_serializable_hash.to_json : nil
            end
          end

          self.value_klass = ::Trax::Model::Attributes::Types::Json::Value
          self.typecaster_klass = ::Trax::Model::Attributes::Types::Json::TypeCaster

          private

          def self.define_model_scopes(model, attribute_name, struct_attribute, option_value)
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
                                       :option => :model_scopes,
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
