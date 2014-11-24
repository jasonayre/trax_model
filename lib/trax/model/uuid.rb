module Trax
  module Model
    class UUID < String
      def model_type
        @model_type ||= ::Trax::Model::Registry.model_type_for_uuid(self)
      end

      def model
        @model ||= model_type ? model_type.find(self) : nil
      end
    end
  end
end
