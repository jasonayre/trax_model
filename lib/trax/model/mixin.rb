module Trax
  module Model
    module Mixin
      extend ::ActiveSupport::Concern

      included do
        self.extend(::ActiveSupport::Concern)

        ::Trax::Model.register_mixin(self)
      end
    end
  end
end
