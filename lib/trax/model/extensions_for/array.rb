module Trax
  module Model
    module ExtensionsFor
      module Array
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Enumerable

        module ClassMethods
          def type
            :array
          end
        end
      end
    end
  end
end
