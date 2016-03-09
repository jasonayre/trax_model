module Trax
  module Model
    module ExtensionsFor
      module Set
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Enumerable

        module ClassMethods
          def type
            :set
          end
        end
      end
    end
  end
end
