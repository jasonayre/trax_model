module Trax
  module Model
    class Registry
      class_attribute :models, :uuid_map

      self.models ||= ::Hashie::Mash.new
      self.uuid_map ||= ::Hashie::Mash.new

      class << self
        delegate :key?, :to => :models
        delegate :each, :to => :models
      end

      def self.register_trax_model(model)
        unless models.key?(model.trax_registry_key)
          models[model.trax_registry_key] = model
        end

        uuid_map[model.trax_defaults.uuid_prefix] = model.trax_registry_key
      end

      def self.model_type_for_uuid(str)
        prefix = str[0..1]

        uuid_map.fetch(prefix)
      end
    end
  end
end
