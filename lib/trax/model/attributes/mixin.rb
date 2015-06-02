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
          self.evaluate_attribute_definitions_blocks if self.ancestors.include?(::ActiveRecord::Base)
        end

        module ClassMethods
          def define_attributes(&block)
            self.instance_variable_set("@_attribute_definitions_block", block)
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
              const_set("Fields", ::Module.new)
              const_get("Fields").extend(::Trax::Model::Attributes::Fields)
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
            model_klass_proxy = ::Trax::Model::Attributes::Definitions.new(self)
            attribute_definition_blocks = fetch_attribute_definitions_in_chain([], self)

            attribute_definition_blocks.each do |blk|
              model_klass_proxy.instance_eval(&blk)
            end
          end
        end

      end
    end
  end
end
