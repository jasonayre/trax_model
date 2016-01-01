module Trax
  module Model
    module ExtensionsForPrimitive
      module String
        extend ::ActiveSupport::Concern

        def to_matchable
          "%#{self.strip}%"
        end

        def uuid
          ::Trax::Model::UUID === self ? ::Trax::Model::UUID.new(self) : nil
        end
      end
    end
  end
end
