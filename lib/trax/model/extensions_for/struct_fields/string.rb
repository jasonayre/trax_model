module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module String
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::Base

          module ClassMethods
            def eq(*_scope_values)
              _scope_values.flat_compact_uniq!
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}') IN(?)", _scope_values)
            end

            def eq_lower(*_scope_values)
              _scope_values.flat_compact_uniq!
              model_class.where("lower(#{parent_definition.field_name} ->> '#{field_name}') IN(?)", _scope_values.map(&:downcase))
            end

            def matches(*_scope_values)
              _scope_values.flat_compact_uniq!
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}') ilike ANY(array[?])", _scope_values.map(&:to_matchable))
            end
          end
        end
      end
    end
  end
end
