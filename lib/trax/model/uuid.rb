module Trax
  module Model
    class UUID < String
      def self.generate(prefix = nil)
        uuid = ::SecureRandom.uuid
        uuid[0..1] = prefix if prefix
        uuid
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
