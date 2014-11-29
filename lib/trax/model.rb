require 'active_record'
require 'default_value_for'
require 'hashie/dash'
require 'hashie/mash'
require_relative './string'

require_relative './validators/email_validator'
require_relative './validators/frozen_validator'
require_relative './validators/subdomain_validator'
require_relative './validators/url_validator'

module Trax
  module Model
    extend ::ActiveSupport::Concern
    extend ::ActiveSupport::Autoload

    autoload :Config
    autoload :Freezable
    autoload :Registry
    autoload :UUID
    autoload :UniqueId
    autoload :Matchable
    autoload :Validators

    include ::Trax::Model::Matchable
    include ::ActiveModel::Dirty

    included do
      class_attribute :trax_defaults

      self.trax_defaults = ::Trax::Model::Config.new

      register_trax_models(self)
    end


    module ClassMethods
      delegate :register_trax_model, :to => "::Trax::Model::Registry"
      delegate :[], :to => :find


      def defaults(options = {})
        options.each_pair do |key, val|
          self.trax_defaults.__send__("#{key}=", val)
        end
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
