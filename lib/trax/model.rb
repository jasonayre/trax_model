require 'active_record'
require 'default_value_for'
require 'hashie/dash'
require 'hashie/mash'
require 'simple_enum'
require_relative './string'
# require_relative './enum'
require_relative './validators/email_validator'
require_relative './validators/frozen_validator'
require_relative './validators/future_validator'
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
    autoload :Registry
    autoload :UUID
    autoload :UUIDPrefix
    autoload :UniqueId
    autoload :Matchable
    autoload :Mixin
    autoload :MTI
    autoload :Restorable
    autoload :STI
    autoload :Validators

    include ::Trax::Model::Matchable
    include ::ActiveModel::Dirty

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
      ::Trax::Model::Restorable
      ::Trax::Model::UniqueId
    end

    eager_autoload_mixins!

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

      def mixin(key, options = {})
        mixin_klass = ::Trax::Model.mixin_registry[key]

        self.class_eval do
          include(mixin_klass) unless self.ancestors.include?(mixin_klass)

          if(options.is_a?(Hash) && !options.blank?)
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
