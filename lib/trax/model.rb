require 'active_record'
require 'default_value_for'
require 'hashie/mash'

module Trax
  module Model
    extend ::ActiveSupport::Concern

    included do
      class_attribute :guid_prefix

      self.trax_defaults = ::Hashie::Mash.new
    end

    module ClassMethods
      def defaults(options={})

      end

      def register_trax_models(*models)
        
      end
    end

    class Registry
      class_attribute :models
    end
  end
end
