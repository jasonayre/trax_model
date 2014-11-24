module Trax
  module Model
    class Registry
      class_attribute :models

      self.models ||= ::Hashie::Mash.new

      class << self
        delegate :key?, :to => :models
        delegate :each, :to => :models
      end

      def self.register_trax_model(model)
        unless models.key?(model.trax_registry_key)
          models[model.trax_registry_key] = model
        end
      end

      def self.model_type_for_uuid(str)
        prefix = str[0..1]

        uuid_map.fetch(prefix)
      end

      def self.uuid_map
        @uuid_map ||= models.values.inject(::Hashie::Mash.new) do |result, model|
          result[model.uuid_prefix] = model
          result
        end
      end
    end
  end
end
