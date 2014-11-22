require 'active_record'
require 'default_value_for'
require 'hashie/mash'

module Trax
  module Model
    extend ::ActiveSupport::Concern

    included do
      class_attribute :guid_prefix

      self.trax_defaults = ::Hashie::Mash.new

      register_trax_models(self)
    end

    module ClassMethods
      def defaults(options={})

      end

      def register_trax_model(model)
        unless Trax::Model::Registry.key?(name)
          Trax::Model::Registry[registry_key] = model
        end
      end

      def registry_key
        name.underscore
      end

      def register_trax_models(*models)
        models.each do |model|
          register_trax_model(model)
        end
      end
    end
  end
end
