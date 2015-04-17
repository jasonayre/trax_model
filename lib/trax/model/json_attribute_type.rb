module Trax
  module Model
    class JsonAttributeType < ActiveRecord::Type::Value
      include ::ActiveRecord::Type::Mutable

      def initialize(*args, target_klass:)
        super(*args)

        @target_klass = target_klass
      end

      def type_cast_from_user(value)
        rval = value.is_a?(@target_klass) ? @target_klass : @target_klass.new(value || {})
        binding.pry
        rval
      end

      def type_cast_from_database(value)
        hash = JSON.parse(value || "{}")
        @target_klass.new(hash)
      end

      def type_cast_for_database(value)
        value.to_hash.to_json
      end
    end
  end
end
