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

      class_attribute :fields

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
        name = name.is_a?(Symbol) ? name.to_s : name
        klass = fields_module.const_set(name.camelize, ::Class.new(::Trax::Model::Attributes[:boolean]::Attribute))
        options[:default] = options.key?(:default) ? options[:default] : nil
        property(name, *args, **options)
      end

      def self.string_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass = fields_module.const_set(name.camelize, ::Class.new(::Trax::Model::Attributes[:string]::Value))
        klass.instance_eval(&block) if block_given?
        validates(name, options[:validates]) if options.key?(:validates)
        options[:default] = options.key?(:default) ? options[:default] : ""

        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, klass)
      end

      def self.struct_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        struct_klass = fields_module.const_set(name.camelize, ::Class.new(::Trax::Model::Struct))
        struct_klass.instance_eval(&block) if block_given?
        options[:default] = {} unless options.key?(:default)
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, struct_klass)
      end

      def self.enum_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        enum_klass = fields_module.const_set(name.camelize, ::Class.new(::Enum))
        enum_klass.instance_eval(&block) if block_given?
        options[:default] = nil unless options.key?(:default)
        define_scopes_for_enum(name, enum_klass) unless options.key?(:define_scopes) && !options[:define_scopes]
        validates(name, options[:validates]) if options.key?(:validates)
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, enum_klass)
      end

      # def self.enum_fields
      #   @enum_fields ||= constants.map(&:superclass)

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

      def self.define_scopes_for_enum(attribute_name, enum_klass)
        model_class = parent.parent

        if model_class.ancestors.include?(::ActiveRecord::Base)
          field_name = name.demodulize.underscore
          attribute_name = enum_klass.name.demodulize.underscore
          scope_name = :"by_#{field_name}_#{attribute_name}"

          model_class.scope(scope_name, lambda{ |*_scope_values|
            _integer_values = enum_klass.select_values(*_scope_values.flat_compact_uniq!)
            model_class.where("#{field_name} -> '#{attribute_name}' IN(#{_integer_values.to_single_quoted_list})")
          })
        end
      end

      def self.to_schema
        ::Trax::Core::Definition.new(
          :source => self.name,
          :name => self.name.demodulize.underscore,
          :type => :struct,
          :fields => self.fields_module.to_schema
        )
      end

      def self.type; :struct end;

      def to_serializable_hash
        _serializable_hash = to_hash

        self.class.fields_module.enums.keys.each do |attribute_name|
          _serializable_hash[attribute_name] = _serializable_hash[attribute_name].try(:to_i)
        end if self.class.fields_module.enums.keys.any?

        _serializable_hash
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
