module Trax
  module Model
    module ExtensionsFor
      module Numeric
        extend ::ActiveSupport::Concern

        include ::Trax::Model::ExtensionsFor::Base

        module ClassMethods
          def between(lower_value, upper_value)
            gt(lower_value).merge(lt(upper_value))
          end

          def in_range(lower_value, upper_value)
            gte(lower_value).merge(lte(upper_value))
          end

          def eq(*_scope_values)
            _scope_values.flat_compact_uniq!
            model_class.where({field_name => _scope_values})
          end

          def gt(value)
            operator = '>'
            model_class.where("#{field_name} #{operator} ?", value)
          end

          def gte(value)
            operator = '>='
            model_class.where("#{field_name} #{operator} ?", value)
          end

          def lt(value)
            operator = '<'
            model_class.where("#{field_name} #{operator} ?", value)
          end

          def lte(value)
            operator = '<='
            model_class.where("#{field_name} #{operator} ?", value)
          end
        end
      end
    end
  end
end
