require 'hashie/extensions/ignore_undeclared'

module Trax
  module Model
    class JsonAttribute < ::Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared

      def initialize(*args, **named_args)
        super(*args)
      end

      def self.property(name, *args)
        super(name, *args)

        # define_method("#{name}=") do |val|
        #   assert_property_required! name, val
        #   assert_property_exists! name
        #
        #   @owner.__send__(@attribute_name)[name] = val
        #   @owner[@attribute_name] = self.to_hash
        # end
      end

      private

      attr_accessor :owner, :attribute_name
    end
  end
end
