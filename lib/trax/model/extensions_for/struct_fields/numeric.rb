module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Numeric
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::Base

          module ClassMethods
            def eq(*_scope_values)
              _scope_values.flat_compact_uniq!
              cast_type = type
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} IN(?)", _scope_values)
            end

            def gt(value)
              cast_type = type
              operator = '>'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", value)
            end

            def gte(value)
              cast_type = type
              operator = '>='
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", value)
            end

            def lt(value)
              cast_type = type
              operator = '<'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", value)
            end

            def lte(value)
              cast_type = type
              operator = '<='
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", value)
            end
          end
        end
      end
    end
  end
end
