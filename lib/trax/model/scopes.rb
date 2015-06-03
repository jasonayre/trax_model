module Trax
  module Model
    module Scopes
      extend ::ActiveSupport::Concern

      module ClassMethods
        def field_scope(attr_name)
          scope attr_name, lambda{ |*_scope_values|
            _scope_values.flat_compact_uniq!
            where(attr_name => _scope_values)
          }
        end
      end
    end
  end
end
