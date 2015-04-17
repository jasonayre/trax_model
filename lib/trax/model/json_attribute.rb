require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    class JsonAttribute < ::Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      include ActiveModel::Validations

      def inspect
        self.to_hash.inspect
      end
    end
  end
end
