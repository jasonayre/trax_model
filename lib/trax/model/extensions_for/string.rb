module Trax
  module Model
    module ExtensionsFor
      module String
        extend ::ActiveSupport::Concern

        include ::Trax::Model::ExtensionsFor::Base

        module ClassMethods
          def eq(*_values)
            _values.flat_compact_uniq!
            model_class.where({field_name => _values})
          end
        end
      end
    end
  end
end
