module Trax
  module Model
    module Attributes
      class Definitions < ::Trax::Model::Struct
        def self.inherited(subklass)
          super(subklass)

          subklass.class_attribute :model
        end

        # def initialize(model)
        #   @model = model
        # end
        #
        # def __getobj__
        #   @model
        # end

        def self.attribute(*args, type:, **options, &block)
          model.trax_attribute(*args, type: type, **options, &block)
        end

        def self.boolean(*args, **options, &block)
          attribute(*args, :type => :boolean, **options, &block)
        end

        def self.enum(*args, **options, &block)
          attribute(*args, type: :enum, **options, &block)
        end

        def self.string(*args, **options, &block)
          attribute(*args, :type => :string, **options, &block)
        end

        def self.struct(*args, **options, &block)
          attribute(*args, :type => :json, **options, &block)
        end
      end
    end
  end
end
