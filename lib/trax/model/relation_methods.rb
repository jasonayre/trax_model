module Trax
  module Model
    module RelationMethods
      extend ::ActiveSupport::Concern

      def fields
        self.parent.fields
      end
    end
  end
end
