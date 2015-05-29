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

        # subklass.fields = {}.dup
        reset_instance_variables(:@fields_module)
      end

      def self.type
        :struct
      end

      # def self.set_fields_module!
      #   const_set("Fields", ::Module.new)
      #   const_get("Fields").extend(::Trax::Model::Attributes::Fields)
      # end

      # def self.fields_module?
      #   const_defined?("Fields")
      # end

      def self.fields_module
        @fields_module ||= begin
          const_set("Fields", ::Module.new)
          const_get("Fields").extend(::Trax::Model::Attributes::Fields)
        end
      end

      def self.boolean_property(name, *args, **options, &block)
        klass = fields_module.const_set(name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:boolean]::Value))
        klass.instance_eval(&block) if block_given?
        # binding.pry
        options[:default] = options.key?(:default) ? options[:default] : nil
        property(name, *args, **options)
        coerce_key(name, klass)
      end

      def self.string_property(name, *args, **options, &block)
        klass = fields_module.const_set(name.to_s.camelize, ::Class.new(::Trax::Model::Attributes[:string]::Value))
        klass.instance_eval(&block) if block_given?
        property(name, *args, **options)
        coerce_key(name, klass)
      end

      def self.struct_property(name, *args, **options, &block)
        # set_fields_module! unless fields_module?
        # struct
        # struct_klass_name = "#{name}".camelize

        struct_klass = fields_module.const_set(name.to_s.camelize, ::Class.new(::Trax::Model::Struct))
        struct_klass.instance_eval(&block) if block_given?

        # puts name.inspect

        options[:default] = {} unless options.key?(:default)
        property(name, *args, **options)
        coerce_key(name, struct_klass)

        # fields[name] = ::Trax::Model::Attributes::Definition.new({
        #   name: name,
        #   type: :struct,
        #   klass: struct_klass
        # })
      end

      def self.enum_property(name, *args, **options, &block)
        # set_fields_module! unless fields_module?

        # enum_klass_name = "fields/#{name}".camelize
        # enum_klass.fields_module
        enum_klass = fields_module.const_set(name.to_s.camelize, ::Class.new(::Enum, &block))

        options[:default] = {} unless options.key?(:default)
        property(name, *args, **options)
        coerce_key(name, enum_klass)

        # fields[name] = ::Trax::Model::Attributes::Definition.new({
        #   name: name,
        #   type: :enum,
        #   klass: enum_klass
        # })
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
