module Trax
  module Model
    module ExtensionsFor
      module Enum
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Base

        module ClassMethods
          def eq(_scope_value)
            model_class.where({field_name => new(_scope_value)})
          end

          def in(*_scope_values)
            _integer_values = select_values(*_scope_values.flat_compact_uniq!)
            _integer_values.map!(&:to_s)
            model_class.where({field_name => _integer_values})
          end
        end
      end
    end
  end
end
