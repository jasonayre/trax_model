module ArelExtensions
  module Matchable
    extend ::ActiveSupport::Concern

    included do
      ::String.class_eval do
        def to_matchable
          "%#{self.strip}%"
        end
      end
    end

    module ClassMethods
      def matching(args = {})
        matches = args.inject(self.all) do |scope, (key, value)|
          node = key.is_a?(Symbol) ? self.arel_table[key] : key

          values = [value]

          match_values = values.flatten.compact.uniq.map!(&:to_matchable)
          scope = scope.where(node.matches_any(match_values))
          scope
        end

        matches
      end
    end
  end
end
