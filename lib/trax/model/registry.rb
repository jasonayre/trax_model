module Trax
  module Model
    class Registry
      class_attribute :models

      self.models ||= ::Hashie::Mash.new

      class << self
        delegate :key?, :to => :models
        delegate :each, :to => :models
        delegate :all, :to => :collection
      end

      def self.collection
        models.try(:values)
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

      def self.next_prefix
        current_prefix = models.values
                               .reject!{|model| !model.try(:uuid_prefix) }
                               .map(&:uuid_prefix)
                               .sort
                               .last

        current_prefix.next
      end

      def self.model_prefixes
        models.try(:keys)
      end

      def self.previous_prefix
        current_prefix = models.values
                               .reject!{|model| !model.try(:uuid_prefix) }
                               .map(&:uuid_prefix)
                               .sort
                               .last

        current_prefix.previous
      end

      def self.uuid_map
        models.values.reject{|model| model.try(:uuid_prefix) == nil }.inject(::Hashie::Mash.new) do |result, model|
          result[model.uuid_prefix] = model
          result
        end
      end
    end
  end
end
