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

        subklass.fields = {}.dup

        subklass.property_types = {}.dup.tap do |hash|
          hash[:structs] = []
          hash[:enums] = []
          hash
        end
      end

      def self.struct_property(name, *args, **options, &block)
        struct_klass_name = "#{name}_structs".classify
        struct_klass = const_set(struct_klass_name, ::Class.new(::Trax::Model::Struct))
        struct_klass.instance_eval(&block)
        options[:default] = {} unless options.key?(:default)
        property(name, *args, **options)
        coerce_key(name, struct_klass)
        property_types[:structs].push(name)
      end

      def self.enum_property(name, *args, **options, &block)
        enum_klass_name = "#{name}_enum".classify
        enum_klass = const_set(enum_klass_name, ::Class.new(::Enum, &block))
        options[:default] = {} unless options.key?(:default)
        property(name, *args, **options)
        coerce_key(name, enum_klass)
        property_types[:enums].push(name)
      end

      class << self
        alias :enum :enum_property
        alias :struct :struct_property
      end

      class Definition < Hashie::Mash
        def schema
          {
            :name => name,
            :type => type,
            :klass => klass
          }
        end
      end
    end
  end
end
