require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    class JsonAttribute < ::Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
    end
  end
end
