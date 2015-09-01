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

      def self.inherited(subklass)
        super(subklass)
      end

      def self.fields_module
        @fields_module ||= begin
          module_name = "#{self.name}::Fields"
          ::Trax::Core::NamedModule.new(module_name, ::Trax::Model::Attributes::Fields)
        end
      end

      def self.fields
        fields_module
      end

      def self.boolean_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass_name = "#{fields_module.name.underscore}/#{name}".camelize
        boolean_klass = ::Trax::Core::NamedClass.new(klass_name, Trax::Model::Attributes[:boolean]::Attribute, :parent_definition => self, &block)
        options[:default] = options.key?(:default) ? options[:default] : nil
        define_where_scopes_for_boolean_property(name, boolean_klass) unless options.key?(:define_scopes) && !options[:define_scopes]
        property(name, *args, **options)
      end

      def self.string_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass_name = "#{fields_module.name.underscore}/#{name}".camelize
        string_klass = ::Trax::Core::NamedClass.new(klass_name, Trax::Model::Attributes[:string]::Value, :parent_definition => self, &block)
        validates(name, options[:validates]) if options.key?(:validates)
        options[:default] = options.key?(:default) ? options[:default] : ""
        define_where_scopes_for_property(name, string_klass) unless options.key?(:define_scopes) && !options[:define_scopes]
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, string_klass)
      end

      def self.struct_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass_name = "#{fields_module.name.underscore}/#{name}".camelize
        struct_klass = ::Trax::Core::NamedClass.new(klass_name, Trax::Model::Struct, :parent_definition => self, &block)
        options[:default] = {} unless options.key?(:default)
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, struct_klass)
      end

      def self.enum_property(name, *args, **options, &block)
        name = name.is_a?(Symbol) ? name.to_s : name
        klass_name = "#{fields_module.name.underscore}/#{name}".camelize
        enum_klass = ::Trax::Core::NamedClass.new(klass_name, ::Enum, :parent_definition => self, &block)
        options[:default] = nil unless options.key?(:default)
        define_scopes_for_enum(name, enum_klass) unless options.key?(:define_scopes) && !options[:define_scopes]
        validates(name, options[:validates]) if options.key?(:validates)
        property(name.to_sym, *args, **options)
        coerce_key(name.to_sym, enum_klass)
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

      def self.define_scopes_for_enum(attribute_name, enum_klass)
        return unless enum_klass.parent_definition.parent_definition.ancestors.include?(::ActiveRecord::Base)

        model_class = enum_klass.parent_definition.parent_definition
        field_name = enum_klass.parent_definition.name.demodulize.underscore
        attribute_name = enum_klass.name.demodulize.underscore
        scope_name = :"by_#{field_name}_#{attribute_name}"

        model_class.scope(scope_name, lambda{ |*_scope_values|
          _integer_values = enum_klass.select_values(*_scope_values.flat_compact_uniq!)
          model_class.where("#{field_name} -> '#{attribute_name}' IN(#{_integer_values.to_single_quoted_list})")
        })
      end

      def self.define_where_scopes_for_boolean_property(attribute_name, property_klass)
        return unless property_klass.parent_definition.parent_definition.ancestors.include?(::ActiveRecord::Base)

        model_class = property_klass.parent_definition.parent_definition
        field_name = property_klass.parent_definition.name.demodulize.underscore
        attribute_name = property_klass.name.demodulize.underscore
        scope_name = :"by_#{field_name}_#{attribute_name}"

        model_class.scope(scope_name, lambda{ |*_scope_values|
          _scope_values.flat_compact_uniq!
          model_class.where("#{field_name} -> '#{attribute_name}' IN(#{_scope_values.to_single_quoted_list})")
        })
      end

      def self.define_where_scopes_for_property(attribute_name, property_klass)
        return unless property_klass.parent_definition.parent_definition.ancestors.include?(::ActiveRecord::Base)

        model_class = property_klass.parent_definition.parent_definition
        field_name = property_klass.parent_definition.name.demodulize.underscore
        attribute_name = property_klass.name.demodulize.underscore
        scope_name = :"by_#{field_name}_#{attribute_name}"

        model_class.scope(scope_name, lambda{ |*_scope_values|
          _scope_values.flat_compact_uniq!
          model_class.where("#{field_name} ->> '#{attribute_name}' IN(#{_scope_values.to_single_quoted_list})")
        })
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
