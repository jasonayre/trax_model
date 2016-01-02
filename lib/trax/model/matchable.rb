module Trax
  module Model
    module Matchable
      extend ::ActiveSupport::Concern

      module ClassMethods
        def matching(args = {})
          matches = args.inject(self.all) do |scope, (key, value)|
            node = key.is_a?(Symbol) ? self.arel_table[key] : key

            values = [value]
            values.flat_compact_uniq!
            values.map!(&:to_matchable)

            scope = scope.where(node.matches_any(values))
            scope
          end

          matches
        end
      end
    end
  end
end
