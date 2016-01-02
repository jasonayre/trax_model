module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Float
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::StructFields::Numeric
        end
      end
    end
  end
end
