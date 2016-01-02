module Trax
  module Model
    module ExtensionsFor
      module Boolean
        extend ::ActiveSupport::Concern
        include ::Trax::Model::ExtensionsFor::Base

        module ClassMethods
          def eq(*_scope_values)
            _scope_values.flat_compact_uniq!
            model_class.where({field_name => _scope_values})
          end

          def is_nil
            eq(nil)
          end

          def is_false
            eq(false)
          end

          def is_true
            eq(true)
          end
        end
      end
    end
  end
end
