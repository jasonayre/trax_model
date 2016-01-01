module Trax
  module Model
    module ExtensionsFor
      module StructFields
        module Time
          extend ::ActiveSupport::Concern

          include ::Trax::Model::ExtensionsFor::Base

          # return unless has_active_record_ancestry?(parent_definition)

          # included do
          #   # model_class = model_class_for_property(property_klass)
          #   attribute_klass = parent_definition
          #   # field_name = property_klass.parent_definition.name.demodulize.underscore
          #   attribute_name = property_klass.name.demodulize.underscore
          #   cast_type = 'timestamp'
          #
          #   { :gt => '>', :lt => '<'}.each_pair do |k, operator|
          #     scope_prefix = as ? as : :"by_#{field_name}_#{attribute_name}"
          #     scope_name = "#{scope_prefix}_#{k}"
          #     # scope_alias = "#{scope_prefix}_#{{:gt => 'after', :lt => 'before' }[k]}"
          #
          #     model_class.scope(scope_name, lambda{ |*_scope_values|
          #       _scope_values.flat_compact_uniq!
          #       model_class.where("(#{field_name} ->> '#{attribute_name}')::#{cast_type} #{operator} ?", _scope_values)
          #     })
          #     model_class.singleton_class.__send__("alias_method", scope_alias.to_sym, scope_name)
          #   end
          # end

          module ClassMethods
            # def gt
            #   model_class.all
            # end

            def after(*_scope_values)
              _scope_values.flat_compact_uniq!
              cast_type = 'timestamp'
              operator = '>'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", _scope_values)
            end

            def before(*_scope_values)
              _scope_values.flat_compact_uniq!
              cast_type = 'timestamp'
              operator = '<'
              model_class.where("(#{parent_definition.field_name} ->> '#{field_name}')::#{cast_type} #{operator} ?", _scope_values)
            end
          end
        end
      end
    end
  end
end
