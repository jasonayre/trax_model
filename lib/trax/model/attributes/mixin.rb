module Trax
  module Model
    module Attributes
      module Mixin
        extend ::Trax::Core::Concern

        included do
          ::Trax::Model::Attributes.config.attribute_types.each_pair do |key, mod|
            include mod::Mixin if mod.const_defined?("Mixin")
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

          def fields_module
            @fields_module ||= begin
              const_set("Fields", ::Module.new)
              const_get("Fields").extend(::Trax::Model::Attributes::Fields)
            end
          end

          def trax_attribute(name, type:, **options, &block)
            raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type) unless ::Trax::Model::Attributes.key?(type)

            if ::Trax::Model::Attributes[type].const_defined?("Mixin")
              attribute_type_definition_method = ::Trax::Model::Attributes[type]::Mixin::ClassMethods.instance_methods.first
              self.send(attribute_type_definition_method, name, **options, &block)
              self.validates(name, options[:validates]) if options.key?(:validates)
            elsif ::Trax::Model::Attributes[type].respond_to?(:define_attribute)
              ::Trax::Model::Attributes[type].define_attribute(self, name, **options, &block)
            else
              raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type)
            end
          end
        end

      end
    end
  end
end
