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

        def boolean(*args, **options, &block)
          attribute(*args, :type => :boolean, **options, &block)
        end

        def enum(*args, **options, &block)
          attribute(*args, :type => :enum, **options, &block)
        end

        def string(*args, **options, &block)
          attribute(*args, :type => :string, **options, &block)
        end

        def struct(*args, **options, &block)
          attribute(*args, :type => :json, **options, &block)
        end
      end
    end
  end
end
