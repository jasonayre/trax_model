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

          def eq_lower(*_values)
            _values.flat_compact_uniq!
            _values.map!(&:downcase)
            model_class.where("lower(#{field_name}) IN(?)", _values)
          end

          def matches(*_values)
            _values.flat_compact_uniq!
            _values.map!(&:to_matchable)
            model_class.where("(#{field_name}) ilike ANY(array[?])", _values)
          end
        end
      end
    end
  end
end
