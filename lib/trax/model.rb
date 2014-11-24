require 'active_record'
require 'default_value_for'
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

    autoload :Registry
    autoload :UUID

    included do
      class_attribute :trax_defaults
      @uuid_prefix = nil
      @uuid_column = nil

      class << self
        attr_reader :uuid_prefix
        attr_accessor :uuid_column
      end

      self.trax_defaults = ::Hashie::Mash.new

      default_value_for(:uuid) {
        ::Trax::Model::UUID.generate(self.uuid_prefix)
      }

      register_trax_models(self)
    end

    def uuid
      ::Trax::Model::UUID.new(super)
    end

    module ClassMethods
      delegate :register_trax_model, :to => "::Trax::Model::Registry"

      def register_trax_models(*models)
        models.each do |model|
          register_trax_model(model)
        end
      end

      def trax_registry_key
        name.underscore
      end

      def uuid_prefix=(prefix)
        if prefix.length != 2 || prefix !~ /[a-f0-9]{2}/
          raise ERROR_MESSAGES[:invalid_uuid_prefix]
        end

        @uuid_prefix = prefix
      end
    end
  end
end
