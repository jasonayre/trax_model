module Trax
  module Model
    module Mixin
      extend ::ActiveSupport::Concern

      def self.before_included(&block)
        prepend Module.new do
          instance_eval(&block)
        end
      end

      included do
        self.extend(::ActiveSupport::Concern)

        ::Trax::Model.register_mixin(self)
      end
    end
  end
end
