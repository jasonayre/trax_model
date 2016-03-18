module Trax
  module Model
    module Base
      extend ::ActiveSupport::Concern

      included do
        self::ActiveRecord_Relation.include(::Trax::Model::RelationMethods)
      end

      def dig(*args)
        try_chain(*args)
      end
    end
  end
end
