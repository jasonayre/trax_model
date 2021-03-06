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

        def array(*args, **options, &block)
          attribute(*args, :type => :array, **options, &block)
        end

        def boolean(*args, **options, &block)
          attribute(*args, :type => :boolean, **options, &block)
        end

        def enum(*args, **options, &block)
          attribute(*args, type: :enum, **options, &block)
        end

        def integer(*args, **options, &block)
          attribute(*args, type: :integer, **options, &block)
        end

        def set(*args, **options, &block)
          attribute(*args, :type => :set, **options, &block)
        end

        def string(*args, **options, &block)
          attribute(*args, :type => :string, **options, &block)
        end

        def struct(*args, **options, &block)
          attribute(*args, :type => :struct, **options, &block)
        end

        def uuid_array(*args, **options, &block)
          attribute(*args, :type => :uuid_array, **options, &block)
        end
      end
    end
  end
end
