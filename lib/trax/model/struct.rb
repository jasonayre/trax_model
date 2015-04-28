module Trax
  module Model
    class Struct < ::Hashie::Dash
      include ::Hashie::Extensions::Dash::IndifferentAccess
      include ::Hashie::Extensions::Coercion
      include ::Hashie::Extensions::IgnoreUndeclared
      include ::ActiveModel::Validations

      class_attribute :property_types

      def self.inherited(subklass)
        super(subklass)

        subklass.property_types = {}.dup.tap do |hash|
          hash[:structs] = []
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
    end
  end
end
