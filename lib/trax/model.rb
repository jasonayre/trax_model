require 'active_record'
require 'default_value_for'
require 'hashie/dash'
require 'hashie/mash'
require_relative './string'

module Trax
  module Model
    extend ::ActiveSupport::Concern
    extend ::ActiveSupport::Autoload

    ERROR_MESSAGES = {
      :invalid_uuid_prefix => [
        "UUID prefix must be 2 characters long",
        "and can only include a-f0-9",
        "for hexadecimal id compatibility"
      ].join("\n")
    }.freeze

    autoload :Config
    autoload :Registry
    autoload :UUID

    included do
      class_attribute :trax_defaults

      self.trax_defaults = ::Trax::Model::Config.new

      register_trax_models(self)
    end

    def uuid
      ::Trax::Model::UUID.new(super)
    end

    module ClassMethods
      delegate :register_trax_model, :to => "::Trax::Model::Registry"
      delegate :[], :to => :find
      delegate :uuid_prefix, :to => :trax_defaults
      delegate :uuid_column, :to => :trax_defaults

      def defaults(options = {})
        options.each_pair do |key, val|
          self.trax_defaults.__send__("#{key}=", val)
        end

        self.default_value_for(:"#{self.trax_defaults.uuid_column}") {
          ::Trax::Model::UUID.generate(self.trax_defaults.uuid_prefix)
        }
      end

      def register_trax_models(*models)
        models.each do |model|
          register_trax_model(model)
        end
      end

      def trax_registry_key
        name.underscore
      end
    end
  end
end
