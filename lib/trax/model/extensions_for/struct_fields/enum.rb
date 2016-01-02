module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Enum
          extend ::ActiveSupport::Concern
          include ::Trax::Model::ExtensionsFor::Base

          module ClassMethods
            def eq(*_scope_values)
              _integer_values = select_values(*_scope_values.flat_compact_uniq!)
              _integer_values.map!(&:to_s)
              model_class.where("#{parent_definition.field_name} -> '#{field_name}' IN(?)", _integer_values)
            end
          end
        end
      end
    end
  end
end
