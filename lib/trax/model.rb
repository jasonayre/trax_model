require 'active_record'
require 'default_value_for'
require 'hashie/dash'
require 'hashie/mash'
require 'hashie/trash'
require 'hashie/extensions/dash/indifferent_access'
require 'simple_enum'
require_relative './validators/boolean_validator'
require_relative './validators/email_validator'
require_relative './validators/frozen_validator'
require_relative './validators/future_validator'
require_relative './validators/subdomain_validator'
require_relative './validators/url_validator'

#trax attribute specific validators
require_relative './validators/enum_attribute_validator'
require_relative './validators/json_attribute_validator'
require_relative './validators/string_attribute_validator'

module Trax
  module Model
    extend ::ActiveSupport::Concern
    extend ::ActiveSupport::Autoload

    autoload :Attributes
    autoload :Config
    autoload :Enum
    autoload :EnumerableExtensions
    autoload :Errors
    autoload :Freezable
    autoload :Registry
    autoload :UUID
    autoload :UUIDPrefix
    autoload :UniqueId
    autoload :Matchable
    autoload :Mixin
    autoload :Mixins
    autoload :MTI
    autoload :Restorable
    autoload :Railtie
    autoload :STI
    autoload :StringExtensions
    autoload :Struct
    autoload :StructExtensions
    autoload :Validators

    include ::Trax::Model::Matchable
    include ::ActiveModel::Dirty
    include ::Trax::Core::InheritanceHooks

    define_configuration_options! do
      option :auto_include, :default => false
      option :auto_include_mixins, :default => []
    end

    #like reverse merge, only assigns attributes which have not yet been assigned
    def reverse_assign_attributes(attributes_hash)
      attributes_to_assign = attributes_hash.keys.reject{|_attribute_name| attribute_present?(_attribute_name) }

      assign_attributes(attributes_hash.slice(attributes_to_assign))
    end

    class << self
      attr_accessor :mixin_registry
    end

    @mixin_registry = {}

    def self.register_mixin(mixin_klass, key = nil)
      mixin_key = mixin_klass.respond_to?(:mixin_registry_key) ? mixin_klass.mixin_registry_key : (key || mixin_klass.name.demodulize.underscore.to_sym)

      return if mixin_registry.key?(mixin_key)
      mixin_registry[mixin_key] = mixin_klass
    end

    def self.root
      ::Pathname.new(::File.path(__FILE__))
    end

    def self.eager_autoload_mixins!
      ::Trax::Model::Attributes::Mixin
      ::Trax::Model::Enum
      ::Trax::Model::Freezable
      ::Trax::Model::Restorable
      ::Trax::Model::UniqueId
      ::Trax::Model::Mixins::FieldScopes
      ::Trax::Model::Mixins::IdScopes
      ::Trax::Model::Mixins::SortByScopes
      ::Trax::Model::Mixins::StiEnum
    end

    eager_autoload_mixins!

    def self.find_by_uuid(uuid)
      ::Trax::Model::UUID.new(uuid).record
    end

    included do
      class_attribute :registered_mixins

      self.registered_mixins = {}

      register_trax_models(self)
    end

    module ClassMethods
      delegate :register_trax_model, :to => "::Trax::Model::Registry"
      delegate :[], :to => :find

      def after_inherited(&block)
        instance_variable_set(:@_after_inherited_block, block)
      end

      def mixin(key, options = {})
        raise ::Trax::Model::Errors::MixinNotRegistered.new(
          model: self.name,
          mixin: key
        )  unless ::Trax::Model.mixin_registry.key?(key)

        mixin_module = ::Trax::Model.mixin_registry[key]
        self.registered_mixins[key] = mixin_module

        self.class_eval do
          include(mixin_module) unless self.ancestors.include?(mixin_module)

          options = {} if options.is_a?(TrueClass)
          options = { options => true } if options.is_a?(Symbol)
          mixin_module.apply_mixin(self, options) if mixin_module.respond_to?(:apply_mixin)

          if mixin_module.instance_variable_defined?(:@_after_included_block)
            block = mixin_module.instance_variable_get(:@_after_included_block)

            instance_exec(options, &block)
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

    ::String.include(::Trax::Model::StringExtensions)

    ::ActiveSupport.run_load_hooks(:trax_model, self)
  end
end

::Trax::Model::Railtie if defined?(::Rails)
