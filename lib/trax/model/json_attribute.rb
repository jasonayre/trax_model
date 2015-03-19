require 'hashie/extensions/ignore_undeclared'
require 'hashie/dash'

module Trax
  module Model
    class JsonAttribute < ::Hashie::Dash
      include ::Hashie::Extensions::IgnoreUndeclared

      def self.field_name
        @field_name ||= name.demodulize.underscore.to_sym
      end

      def self.field_ivar_name
        @field_ivar_name ||= :"@#{field_name}"
      end

      def initialize(_record, *args)
        super(*args)

        @_record = _record
        @_is_dirty = false
      end

      # def [](property)
      #   assert_property_exists! property
      #   value = super(property)
      #   # If the value is a lambda, proc, or whatever answers to call, eval the thing!
      #   if value.is_a? Proc
      #     self[property] = value.call # Set the result of the call as a value
      #   else
      #     yield value if block_given?
      #     value
      #   end
      # end
      # Set a value on the Dash in a Hash-like way. Only works
      # on pre-existing properties.
      def []=(property, value)
        # assert_property_required! property, value
        # assert_property_exists! property
        result = super(property, value)
        binding.pry
        result = instance_variable_set(self.class.field_ivar_name, self) if [true, false].include?(@is_dirty)

        result
      end



      private

      def is_dirty?
        !!@_is_dirty
      end

      def field
        @field ||= record.json_attribute_fields[self.class.field_name]
      end

      def record
        @_record
      end


      # def initialize(options = {})
      #   super(options.symbolize_keys!)
      # end
    end
  end
end
