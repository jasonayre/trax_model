module Trax
  module Model
    module ExtensionsFor
      module Enumerable
        extend ::ActiveSupport::Concern

        include ::Trax::Model::ExtensionsFor::Base

        module ClassMethods
          def contains(*_values)
            _values.flat_compact_uniq!
            model_class.where("#{field_name} ?| array[:values]", :values => _values)
          end
        end
      end
    end
  end
end
