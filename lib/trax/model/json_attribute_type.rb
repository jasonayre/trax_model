module Trax
  module Model
    class JsonAttributeType < ActiveRecord::Type::Value
      include ::ActiveRecord::Type::Mutable

      def self.attribute_class_name
        name.gsub("Type", "Attribute")
      end

      def initialize(*args, target_klass:)
        super(*args)

        @target_klass = target_klass
      end

      # def self.inherited(subclass)
      #   super(subclass)
      #
      #   binding.pry
      #
      #   subclass.class_attribute(:attribute_class_name)
      #   subclass.attribute_class_name = subclass.name.gsub("Type", "")
      # end

      def type_cast(value)
        return value if value.is_a?(@target_klass)

        wrapped_value = value.present? ? @target_klass.new(value) : @target_klass.new
        # value = @target_klass.new(value || {}) unless value.is_a?(@target_klass)
        binding.pry

        super(wrapped_value)
      end

      #uhh i shouldnt have to symbolize keys here?
      def type_cast_from_database(value)
        hash = JSON.parse(value)
        @target_klass.new(hash.symbolize_keys!)
      end

      def type_cast_for_database(value)
        value.to_hash.to_json
      end
    end
  end
end
