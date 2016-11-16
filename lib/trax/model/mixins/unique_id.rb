module Trax
  module Model
    module Mixins
      module UniqueId
        extend ::Trax::Model::Mixin

        define_configuration_options! do
          option :uuid_column, :default => :id
          option :uuid_map, :default => {}
        end

        after_included do |options|
          define_configuration_options!(:unique_id) do
            option :uuid_prefix,
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

            option :uuid_column, :default => ::Trax::Model::Mixins::UniqueId.config.uuid_column

            klass do
              def uuid_prefix=(prefix)
                if(::Trax::Model::Mixins::UniqueId.config.uuid_map.values.include?(prefix) && ::Trax::Model::Mixins::UniqueId.config.uuid_map[self.source.name] != prefix)
                  raise ::Trax::Model::Errors::DuplicatePrefixRegistered.new(:prefix => prefix, :model => self.source.name)
                end

                ::Trax::Model::Mixins::UniqueId.config.uuid_map[self.source.name] = prefix
                super(::Trax::Model::UUIDPrefix.new(prefix))
              end
            end

          end

          #grab prefix from uuid registry if uuids are defined in an initializer
          if ::Trax::Model.mixin_registry.key?(:unique_id) && ::Trax::Model::UUID.klass_prefix_map.key?(self.name)
            self.unique_id_config.uuid_prefix = ::Trax::Model::UUID.klass_prefix_map[self.name]
          end

          self.unique_id_config.merge!(options)

          if(self.unique_id_config.uuid_prefix)
            default_value_for(:"#{self.unique_id_config.uuid_column}") {
              generate_uuid
            }
          end
        end

        def generate_uuid!
          self[self.class.unique_id_config.uuid_column] = self.class.generate_uuid
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
          def generate_uuid
            ::Trax::Model::UUID.generate(uuid_prefix)
          end

          def uuid_prefix
            self.unique_id_config.uuid_prefix
          end
        end
      end
    end
  end
end
