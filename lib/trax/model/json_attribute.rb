require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    class JsonAttribute < ::Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      include ActiveModel::Validations

      def self.permitted_keys
        @permitted_keys ||= properties.map(&:to_sym)
      end

      def inspect
        self.to_hash.inspect
      end
    end
  end
end
