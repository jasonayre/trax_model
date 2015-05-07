module Trax
  module Model
    class JsonAttributeType < ActiveRecord::Type::Value
      include ::ActiveRecord::Type::Mutable

      def initialize(*args, target_klass:)
        super(*args)

        @target_klass = target_klass
      end

      def type_cast_from_user(value)
        value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
      end

      def type_cast_from_database(value)
        value.present? ? @target_klass.new(JSON.parse(value)) : value
      end

      def type_cast_for_database(value)
        value.present? ? value.to_hash.to_json : nil
      end
    end
  end
end
