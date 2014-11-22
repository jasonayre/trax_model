module Trax
  module Model
    class Registry
      class_attribute :models

      self.models ||= ::Hashie::Mash.new
      self.guid_map ||= ::Hashie::Mash.new

      def self.register(model)
        unless models.key?(model.trax_registry_key)
          models[model.trax_registry_key] = model
        end

        guid_map[model.guid_prefix] = model.trax_registry_key
      end
    end
  end
end
