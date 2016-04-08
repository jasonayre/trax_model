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

        def nil?
          __getobj__.nil?
        end

        def self.symbolic_name
          name.demodulize.underscore.to_sym
        end

        def self.to_sym
          :value
        end
      end
    end
  end
end
