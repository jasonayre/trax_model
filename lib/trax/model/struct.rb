require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'hashie/extensions/dash/indifferent_access'

module Trax
  module Model
    class Struct < ::Hashie::Dash
      include ::Hashie::Extensions::Dash::IndifferentAccess
      include ::Hashie::Extensions::Coercion
      include ::Hashie::Extensions::IgnoreUndeclared
      include ::Hashie::Extensions::Dash::PropertyTranslation
      include ::ActiveModel::Validations

      class_attribute :property_types, :fields

      def self.inherited(subklass)
        super(subklass)

        reset_instance_variables(:@fields_module)
      end

      def self.fields_module
        @fields_module ||= begin
          const_set("Fields", ::Module.new)
          const_get("Fields").extend(::Trax::Model::Attributes::Fields)
        end
      end

      def self.boolean_property(name, *args, **options, &block)
        name_as_string = name.is_a?(Symbol) ? name.to_s : name
        klass = fields_module.const_set(name_as_string.camelize, ::Class.new(::Trax::Model::Attributes[:boolean]::Attribute))
        options[:default] = options.key?(:default) ? options[:default] : nil
        property(name_as_string, *args, **options)
      end

      def self.string_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass = fields_module.const_set(name.camelize, ::Class.new(::Trax::Model::Attributes[:string]::Value))
        klass.instance_eval(&block) if block_given?
        property(name, *args, **options)
        coerce_key(name, klass)
      end

      def self.struct_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        struct_klass = fields_module.const_set(name.camelize, ::Class.new(::Trax::Model::Struct))
        struct_klass.instance_eval(&block) if block_given?
        options[:default] = {} unless options.key?(:default)
        property(name, *args, **options)
        coerce_key(name, struct_klass)
      end

      def self.enum_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        enum_klass = fields_module.const_set(name.camelize, ::Class.new(::Enum))
        enum_klass.instance_eval(&block) if block_given?
        options[:default] = nil unless options.key?(:default)
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, enum_klass)
      end

      class << self
        alias :boolean :boolean_property
        alias :enum :enum_property
        alias :struct :struct_property
        alias :string :string_property
      end

      def value
        self
      end
    end
  end
end
