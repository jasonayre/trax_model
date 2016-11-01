module Trax
  module Model
    module Attributes
      module Dsl
        extend ::Trax::Core::Concern

        after_included do
          evaluate_attribute_definitions_blocks
        end

        module ClassMethods
          def define_attributes(&block)
            @_attribute_definitions_block ||= ::Set.new
            @_attribute_definitions_block << block
          end

          def fields_module
            @fields_module ||= begin
              module_name = "#{self.name}::Fields"
              ::Trax::Core::NamedModule.new(module_name, ::Trax::Model::Attributes::Fields, :definition_context => self)
            end
          end

          def fields
            @fields ||= fields_module
          end

          def trax_attribute(name, type:, **options, &block)
            raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type) unless ::Trax::Model::Attributes.key?(type)

            if ::Trax::Model::Attributes[type].respond_to?(:define_attribute)
              ::Trax::Model::Attributes[type].define_attribute(self, name, **options, &block)
              self.validates(name, options[:validates]) if options.key?(:validates)
            else
              raise ::Trax::Model::Attributes::Errors::UnknownAttributeType.new(type: type)
            end
          end

          def evaluate_attribute_definitions_blocks
            model_klass_proxy = ::Trax::Model::Attributes::Definitions.new(self)
            attribute_definition_blocks = self.superclasses_until(::ActiveRecord::Base, self, [ self ])
                                              .map{ |klass| klass.instance_variable_get(:@_attribute_definitions_block).to_a }
                                              .flatten
                                              .compact

            attribute_definition_blocks.each do |blk|
              model_klass_proxy.instance_eval(&blk)
            end if attribute_definition_blocks.any?
          end
        end
      end
    end
  end
end
