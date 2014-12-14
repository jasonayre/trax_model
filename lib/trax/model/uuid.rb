module Trax
  module Model
    class UUID < String
      class_attribute :prefix_map

      self.prefix_map = ::Hashie::Mash.new

      def self.klass_prefix_map
        prefix_map.invert
      end

      def self.generate(prefix = nil)
        uuid = ::SecureRandom.uuid
        uuid[0..1] = prefix if prefix
        uuid
      end

      def self.prefix(prefix_value, klass)
        if prefix_map.has_key(:"#{prefix_value}") && prefix_map[:"#{prefix_value}"] == klass
          raise ::Trax::Model::Errors::DuplicatePrefix.new(prefix_value)
        end

        prefix_map[:"#{prefix_value}"] = klass
      end

      def self.register(&block)
        instance_exec(&block)
      end

      def record
        @record ||= record_type ? record_type.find_by(:"#{record_type.uuid_column}" => self) : nil
      end

      def record_type
        @record_type ||= ::Trax::Model::Registry.model_type_for_uuid(self)
      end
    end
  end
end
