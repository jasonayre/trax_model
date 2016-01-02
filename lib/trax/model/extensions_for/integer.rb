module Trax
  module Model
    module ExtensionsFor
      module Integer
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Numeric
      end
    end
  end
end
