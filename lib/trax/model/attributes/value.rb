module Trax
  module Model
    module Attributes
      class Value < SimpleDelegator
        include ::ActiveModel::Validations

        def initialize(val)
          @value = val
        end

        def __getobj__
          @value
        end

        def self.symbolic_name
          name.demodulize.underscore.to_sym
        end
      end
    end
  end
end
