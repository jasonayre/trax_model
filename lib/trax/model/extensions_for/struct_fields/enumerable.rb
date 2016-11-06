module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Enumerable
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::Base

          module ClassMethods
            def contains(*_values)
              _values.flat_compact_uniq!
              model_class.where("(#{parent_definition.field_name} -> '#{field_name}' ?| array[:values])", :values => _values)
            end

            def does_not_contain(*_values)
              _values.flat_compact_uniq!
              model_class.where.not("(#{parent_definition.field_name} -> '#{field_name}' ?| array[:values])", :values => _values)
            end

            def length_eq(value)
              model_class.where("(JSONB_ARRAY_LENGTH(#{parent_definition.field_name} -> '#{field_name}') = ?)", value)
            end

            def length_gt(value)
              model_class.where("(JSONB_ARRAY_LENGTH(#{parent_definition.field_name} -> '#{field_name}') > ?)", value)
            end

            def length_lt(value)
              model_class.where("(JSONB_ARRAY_LENGTH(#{parent_definition.field_name} -> '#{field_name}') < ?)", value)
            end

            def length_gte(value)
              model_class.where("(JSONB_ARRAY_LENGTH(#{parent_definition.field_name} -> '#{field_name}') >= ?)", value)
            end

            def length_lte(value)
              model_class.where("(JSONB_ARRAY_LENGTH(#{parent_definition.field_name} -> '#{field_name}') <= ?)", value)
            end
          end
        end
      end
    end
  end
end
