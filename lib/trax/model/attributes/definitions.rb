module Trax
  module Model
    module Attributes
      class Definitions < ::SimpleDelegator
        def initialize(model)
          @model = model
        end

        def __getobj__
          @model
        end

        def attribute(*args, type:, **options, &block)
          @model.trax_attribute(*args, type: type, **options, &block)
        end
      end
    end
  end
end
