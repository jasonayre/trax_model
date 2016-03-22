module Trax
  module Model
    module RelationMethods
      extend ::ActiveSupport::Concern

      def fields
        self.klass.fields
      end
    end
  end
end
