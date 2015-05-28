module Trax
  module Model
    module Attributes
      class Definition < SimpleDelegator
        attr_reader :name, :klass

        def initialize(name, klass)
          @name = name
          @klass = klass
        end

        def __getobj__
          @klass
        end
      end
    end
  end
end
