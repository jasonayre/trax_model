require 'active_record'
require 'default_value_for'
require 'hashie/dash'
require 'hashie/mash'
require 'simple_enum'
require_relative './string'
require_relative './validators/email_validator'
require_relative './validators/frozen_validator'
require_relative './validators/future_validator'
require_relative './validators/json_attribute_validator'
require_relative './validators/subdomain_validator'
require_relative './validators/url_validator'

module Trax
  module Model
    extend ::ActiveSupport::Concern
    extend ::ActiveSupport::Autoload

    autoload :Config
    autoload :Enum
    autoload :Errors
    autoload :Freezable
    autoload :JsonAttribute
    autoload :JsonAttributes
    autoload :Registry
    autoload :UUID
    autoload :UUIDPrefix
    autoload :UniqueId
    autoload :Matchable
    autoload :Mixin
    autoload :MTI
    autoload :Restorable
    autoload :Railtie
    autoload :STI
    autoload :Validators

    include ::Trax::Model::Matchable
    include ::ActiveModel::Dirty

    define_configuration_options! do
      option :auto_include, :default => false
      option :auto_include_mixins, :default => []
    end

    class << self
      attr_accessor :mixin_registry
    end

    @mixin_registry = {}

    def self.register_mixin(mixin_klass)
      mixin_key = mixin_klass.name.demodulize.underscore.to_sym
      mixin_registry[mixin_key] = mixin_klass
    end

    def self.eager_autoload_mixins!
      ::Trax::Model::Enum
      ::Trax::Model::Freezable
      ::Trax::Model::JsonAttributes
      ::Trax::Model::Restorable
      ::Trax::Model::UniqueId
    end

    eager_autoload_mixins!

    included do
      register_trax_models(self)
    end

    module ClassMethods
      delegate :register_trax_model, :to => "::Trax::Model::Registry"
      delegate :[], :to => :find

      def mixin(key, options = {})
        mixin_klass = ::Trax::Model.mixin_registry[key]

        self.class_eval do
          unless self.ancestors.include?(mixin_klass)
            include(mixin_klass)
            mixin_klass.apply_mixin(self, options) if mixin_klass.respond_to?(:apply_mixin)
          end
        end
      end

      def mixins(*args)
        options = args.extract_options!

        if(!options.blank?)
          options.each_pair do |key, val|
            self.mixin(key, val)
          end
        else
          args.map{ |key| mixin(key) }
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

::Trax::Model::Railtie if defined?(Rails)
