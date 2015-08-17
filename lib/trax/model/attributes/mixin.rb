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

        after_included do
          evaluate_attribute_definitions_blocks
        end

        module ClassMethods
          def define_attributes(&block)
            # self.const_set("AttributeDefinitions", ::Class.new(::Trax::Model::Attributes::Definitions))
            # definitions = self.const_get("AttributeDefinitions")
            attribute_definitions.model = self
            self.instance_variable_set("@_attribute_definitions_block", block)
          end

          def attribute_definitions
            @attribute_definitions ||= begin
              const_set("AttributeDefinitions", ::Class.new(::Trax::Model::Attributes::Definitions)) unless const_defined?("AttributeDefinitions")
              const_get("AttributeDefinitions")
            end
          end

          #recursively search direct parent classes for attribute definitions, so we can fully support
          #inheritance
          def fetch_attribute_definitions_in_chain(_attribute_definitions_blocks = [], klass=nil)
            _attribute_definitions_blocks.push(klass.instance_variable_get("@_attribute_definitions_block")) if klass && klass.instance_variable_defined?("@_attribute_definitions_block")

            if klass && klass.superclass != ::ActiveRecord::Base
              return fetch_attribute_definitions_in_chain(_attribute_definitions_blocks, klass.superclass)
            else
              return _attribute_definitions_blocks.compact
            end
          end

          def fields_module
            @fields_module ||= begin
              attribute_definitions.const_set("Fields", Module.new) unless attribute_definitions.const_defined?("AttributeDefinitions")
              attribute_definitions.const_get("Fields").extend(::Trax::Model::Attributes::Fields)

              # const_set("AttributeDefinitions", ::Class.new(::Trax::Model::Attributes::Definitions))
              # const_get("AttributeDefinitions::Fields")
            end
          end

          def fields
            @fields ||= fields_module
          end

          def trax_attribute(name, type:, **options, &block)
            raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type) unless ::Trax::Model::Attributes.key?(type)

            if ::Trax::Model::Attributes[type].const_defined?("Mixin")
              attribute_type_definition_method = ::Trax::Model::Attributes[type]::Mixin::ClassMethods.instance_methods.first
              self.send(attribute_type_definition_method, name, **options, &block)
              self.validates(name, options[:validates]) if options.key?(:validates)
            elsif ::Trax::Model::Attributes[type].respond_to?(:define_attribute)
              ::Trax::Model::Attributes[type].define_attribute(self, name, **options, &block)
              self.validates(name, options[:validates]) if options.key?(:validates)
            else
              raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type)
            end
          end

          def evaluate_attribute_definitions_blocks
            attribute_definition_blocks = self.superclasses_until(::ActiveRecord::Base, self, [ self ]).map{ |klass| klass.instance_variable_get(:@_attribute_definitions_block) }.compact

            # binding.pry
            attribute_definitions.instance_eval(&attribute_definition_blocks.last) if attribute_definition_blocks.any?

            # attribute_definition_blocks.each do |blk|
            #   attribute_definitions.instance_eval(&blk)
            #   # const_get("AttributeDefinitions").instance_eval(&blk)
            #   # model_klass_proxy.class_eval(&blk)
            # end if attribute_definition_blocks.any?
          end
        end

      end
    end
  end
end
