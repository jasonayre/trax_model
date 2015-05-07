module Trax
  module Model
    module Attributes
      module Mixin
        def self.mixin_registry_key; :attributes end;

        extend ::Trax::Model::Mixin

        included do
          class_attribute :trax_attribute_fields

          self.trax_attribute_fields = ::ActiveSupport::HashWithIndifferentAccess.new

          ::Trax::Model::Attributes.config.attribute_types.each_pair do |key, mod|
            include mod::Mixin
          end
        end

        module ClassMethods
          # so we can keep all our definitions in same place, and largely so we
          # can use attribute method to define methods
          #probably overkill but..
          def define_attributes(&block)
            model_klass_proxy = ::Trax::Model::Attributes::Definitions.new(self)
            model_klass_proxy.instance_eval(&block)
          end

          def trax_attribute(name, type:, **options, &block)
            trax_attribute_fields[type] ||= {}

            raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type) unless ::Trax::Model::Attributes.key?(type)
            attribute_type_definition_method = ::Trax::Model::Attributes[type]::Mixin::ClassMethods.instance_methods.first

            self.send(attribute_type_definition_method, name, **options, &block)

            self.validates(name, options[:validates]) if options.key?(:validates)
          end
        end

      end
    end
  end
end
