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

      included do
        #grab prefix from uuid registry if using that
        if ::Trax::Model::UUID.klass_prefix_map.has_key?(self.name)
          self.trax_defaults.uuid_prefix = ::Trax::Model::UUIDPrefix.new(klass_prefix_map[self.name])
        end
      end

      def uuid
        uuid_column = self.class.trax_defaults.uuid_column
        uuid_value = (uuid_column == :uuid) ? super : __send__(uuid_column)

        ::Trax::Model::UUID.new(uuid_value)
      end

      #i.e. Blog::Post
      def uuid_type
        uuid.record_type
      end

      #i.e. 'Blog::Post'
      def uuid_type_name
        uuid.record_type.name
      end

      #i.e, Blog::Post will = post
      def uuid_type_slug
        uuid.record_type.name.demodulize.underscore
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
