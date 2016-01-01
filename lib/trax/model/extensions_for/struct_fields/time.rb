module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Time
          extend ::ActiveSupport::Concern

          include ::Trax::Model::ExtensionsFor::Base

          module ClassMethods
            def after(*_scope_values)
              _scope_values.flat_compact_uniq!
              cast_type = 'timestamp'
              operator = '>'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", _scope_values)
            end

            def before(*_scope_values)
              _scope_values.flat_compact_uniq!
              cast_type = 'timestamp'
              operator = '<'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", _scope_values)
            end

            def between(first_time, second_time)
              after(first_time).merge(before(second_time))
            end
          end
        end
      end
    end
  end
end
