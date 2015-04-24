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

        def attribute(*args, **options, &block)
          @model.trax_attribute(*args, **options, &block)
        end
      end
    end
  end
end
