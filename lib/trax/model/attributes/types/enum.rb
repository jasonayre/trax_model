require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    module Attributes
      module Types
        class Enum < ::Trax::Model::Attributes::Type
          class EnumValue
            attr_reader :name, :hash

            def initialize(name, hash)
              @name = name.to_s
              @hash = hash
            end

            def include?(key)
              hash.key?(key.to_s) || hash.value?(key)
            end

            def key(value)
              key = hash.key(value)
              key.to_sym if key
            end

            def value(key)
              value = hash[key.to_s]
              value = key if hash.value?(key)
              value
            end
            alias_method :[], :value

            def each_pair(&block)
              hash.each_pair(&block)
            end
            alias_method :each, :each_pair

            def map(&block)
              hash.map(&block)
            end

            def keys
              hash.keys
            end

            def values_at(*keys)
              keys = keys.map(&:to_s)
              hash.values_at(*keys)
            end

            def to_s
              name
            end
          end

          class Value < ::Trax::Model::Attributes::Value
            def self.inherited(subklass)
              subklass.class_attribute :mapping
              subklass.mapping = {}.with_indifferent_access
            end

            def self.values=(values)
              if values.is_a?(Array)
                values.each_with_index{|k,i| mapping[k] = i }
              elsif values.is_a?(Hash)
                mapping.merge!(values)
              end

              self.class_attribute :inverted_mapping
              inverted_mapping = mapping.dup.invert

              mapping.freeze
              inverted_mapping.freeze
            end

            attr_accessor :integer_value, :name

            def initialize(val)
              if val.is_numeric?
                initialize_with_integer(val)
              else
                initialize_with_name(val)
              end
            end

            def initialize_with_integer(val)
              @integer_value = val
              @name =
            end

            def initialize_with_name(val)
              @name = val
            end

            def integer_value=(val)
              super(val)
              name = self.integer_value

            def set_integer_value(val)

            end

            def __getobj__
              @value
            end


            def to_i
              @integer_value
            end
          end

          class TypeCaster < ActiveRecord::Type::Integer
            def initialize(*args, target_klass:)
              super(*args)

              @target_klass = target_klass
            end

            def type_cast_from_user(value)
              @target_klass.new(super(value)) unless value.nil?
            end

            def type_cast_from_database(value)
              @target_klass.new(super(value)) unless value.nil?
            end

            def type; :enum end;
          end

          module Mixin
            def self.mixin_registry_key; :enum_attributes end;

            extend ::Trax::Model::Mixin
            include ::Trax::Model::Attributes::Mixin
            include ::Trax::Model::Enum

            module ClassMethods
              def enum_attribute(attribute_name, values:, **options, &block)
                attributes_klass_name = "#{attribute_name}_attributes".classify
                attributes_klass = const_set(attributes_klass_name, ::Class.new(::Trax::Model::Attributes[:enum]::Value))
                attributes_klass.values = values

                options.delete(:validates) if options.key?(:validates)

                # as_enum(attribute_name, values, **options)
                attribute(attribute_name, ::Trax::Model::Attributes[:enum]::TypeCaster.new(target_klass: attributes_klass))

                define_method("#{attribute_name}=") do |val|
                  current_value = read_attribute(attribute_name)
                  old_value = values[current_value] if current_value
                  set_attribute_was(attribute_name, old_value) if old_value && old_value != val

                  super(val)
                end
              end
            end
          end
        end
      end
    end
  end
end
