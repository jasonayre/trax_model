module Trax
  module Model
    module UniqueId
      extend ::ActiveSupport::Concern

      ERROR_MESSAGES = {
        :invalid_uuid_prefix => [
          "UUID prefix must be 2 characters long",
          "and can only include a-f0-9",
          "for hexadecimal id compatibility"
        ].join("\n")
      }.freeze

      def uuid
        ::Trax::Model::UUID.new(super)
      end

      #i.e, Blog::Post will = post
      def uuid_type
        uuid.record_type.name.demodulize.underscore
      end

      #i.e. Blog::Post
      def uuid_type_full
        uuid.record_type.name
      end

      module ClassMethods
        delegate :uuid_prefix, :to => :trax_defaults
        delegate :uuid_column, :to => :trax_defaults

        def defaults(*args)
          super(*args)

          self.default_value_for(:"#{self.trax_defaults.uuid_column}") {
            ::Trax::Model::UUID.generate(self.trax_defaults.uuid_prefix)
          }
        end
      end
    end
  end
end
