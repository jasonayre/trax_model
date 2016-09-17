module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Set
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::StructFields::Enumerable
        end
      end
    end
  end
end
