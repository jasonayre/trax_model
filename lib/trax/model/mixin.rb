module Trax
  module Model
    module Mixin
      def self.extended(base)
        base.extend(::ActiveSupport::Concern)

        super(base)

        ::Trax::Model.register_mixin(base)
      end

      def after_included(&block)
        self.instance_variable_set(:@_after_included_block, block)
      end

      def mixed_in(&block)
        after_included(&block)
      end

      def mixed(&block)
        after_included(&block)
      end
    end
  end
end
