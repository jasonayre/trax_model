module Trax
  module Model
    module Validators
      extend ::ActiveSupport::Autoload

      autoload :AssociatedBubblingValidator

      def self.register(mod)
        mod.include(::Trax::Model::Validators::RegisterValidator)
      end

      module RegisterValidator
        def self.included(base)
          ::ActiveRecord::Base.extend(base::ValidationHelperMethod) if base.const_defined?("ValidationHelperMethod")
        end
      end
    end
  end
end
