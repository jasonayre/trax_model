module Trax
  module Model
    module Attributes
      class Value < SimpleDelegator
        include ::Trax::Core::InheritanceHooks

        def self.symbolic_name
          name.demodulize.underscore.to_sym
        end
      end
    end
  end
end
