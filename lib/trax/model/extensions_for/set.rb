module Trax
  module Model
    module ExtensionsFor
      module Set
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Enumerable
      end
    end
  end
end
