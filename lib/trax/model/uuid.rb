module Trax
  module Model
    class UUID < String
      class_attribute :prefix_map
      self.prefix_map = ::Hashie::Mash.new

      def self.===(val)
        return false unless (val.is_a?(::Trax::Model::UUID) || val.is_a?(::String)) && val.length == 36
        return true if val.is_a?(::Trax::Model::UUID)

        #i.e. if we have 2 and 3 digit lengths, for value 'ABCDE' return ['AB', 'ABC']
        value_samples = prefix_lengths.map do |limit|
          val[0..(limit-1)]
        end

        return value_samples.any?{|sample| prefixes.include?(sample) }
      end

      def self.klass_prefix_map
        prefix_map.invert
      end

      def self.generate(prefix = nil)
        uuid = ::SecureRandom.uuid
        uuid[0..(prefix.length-1)] = prefix if prefix
        uuid
      end

      def self.prefix(prefix_value, klass)
        if prefix_map.has_key(:"#{prefix_value}") && prefix_map[:"#{prefix_value}"] == klass
          raise ::Trax::Model::Errors::DuplicatePrefix.new(prefix_value)
        end

        prefix_map[:"#{prefix_value}"] = klass
      end

      def self.prefixes
        @prefixes ||= ::Trax::Model::Registry.uuid_map.keys
      end

      def self.prefix_lengths
        @prefix_lengths ||= prefixes.map(&:length).uniq
      end

      def self.register(&block)
        instance_exec(&block)
      end

      def record
        @record ||= record_type ? record_type.find_by(:"#{record_type.unique_id_config.uuid_column}" => self) : nil
      end

      def record_type
        @record_type ||= ::Trax::Model::Registry.model_type_for_uuid(self)
      end
    end
  end
end
