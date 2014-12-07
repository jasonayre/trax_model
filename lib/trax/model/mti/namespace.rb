module Trax
  module Model
    module MTI
      module Namespace
        extend ::Trax::Core::EagerAutoloadNamespace

        class << self
          attr_reader :base_mti_model
        end

        def self.base_model(model)
          @base_mti_model = model
        end

        def self.all
          @all ||= base_mti_model.subclasses
        end
      end
    end
  end
end
