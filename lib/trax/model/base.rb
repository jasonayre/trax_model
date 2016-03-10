module Trax
  module Model
    module Base
      extend ::ActiveSupport::Concern

      def dig(*args)
        try_chain(*args)
      end
    end
  end
end
