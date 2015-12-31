module Trax
  module Model
    module ExtensionsFor
      module String
        extend ::ActiveSupport::Concern

        def uuid
          ::Trax::Model::UUID === self ? ::Trax::Model::UUID.new(self) : nil
        end
      end
    end
  end
end
