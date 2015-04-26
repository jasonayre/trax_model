module Trax
  module Model
    module UniqueId
      extend ::Trax::Model::Mixin

      define_configuration_options! do
        option :uuid_column, :default => :id
        option :uuid_map, :default => {}
      end

      included do
        define_configuration_options!(:unique_id) do
          option :uuid_prefix,
                 :setter => lambda{ |prefix|
                   if(::Trax::Model::UniqueId.config.uuid_map.values.include?(prefix) && ::Trax::Model::UniqueId.config.uuid_map[self.source.name] != prefix)
                     raise ::Trax::Model::Errors::DuplicatePrefixRegistered.new(:prefix => prefix, :model => self.source.name)
                   end

                   ::Trax::Model::UniqueId.config.uuid_map[self.source.name] = prefix
                   ::Trax::Model::UUIDPrefix.new(prefix)
                 },
                 :validates => {
                   :exclusion => {
                     :in => ::Trax::Model::Registry.uuid_map.values
                   },
                   :inclusion => {
                     :in => ::Trax::Model::UUIDPrefix.all,
                     :message => "%{value} not a valid uuid prefix!\nRun Trax::Model::UUIDPrefix.all for valid prefix list"
                   },
                   :allow_nil => true
                 }

          option :uuid_column, :default => ::Trax::Model::UniqueId.config.uuid_column
        end

        #grab prefix from uuid registry if uuids are defined in an initializer
        if ::Trax::Model.mixin_registry.key?(:unique_id) && ::Trax::Model::UUID.klass_prefix_map.key?(self.name)
          self.unique_id_config.uuid_prefix = ::Trax::Model::UUID.klass_prefix_map[self.name]
        end
      end

      after_included do |options|
        self.unique_id_config.merge!(options)

        if(self.unique_id_config.uuid_prefix)
          default_value_for(:"#{self.unique_id_config.uuid_column}") {
            ::Trax::Model::UUID.generate(self.unique_id_config.uuid_prefix)
          }
        end
      end

      def uuid
        uuid_column = self.class.unique_id_config.uuid_column
        uuid_value = (uuid_column == "uuid") ? super : __send__(uuid_column)

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
        def uuid_prefix
          self.unique_id_config.uuid_prefix
        end
      end

      # def self.apply_mixin(target, options)
      #   target.unique_id_config.merge!(options)
      #
      #   if(target.unique_id_config.uuid_prefix)
      #     target.default_value_for(:"#{target.unique_id_config.uuid_column}") {
      #       ::Trax::Model::UUID.generate(target.unique_id_config.uuid_prefix)
      #     }
      #   end
      # end
    end
  end
end
