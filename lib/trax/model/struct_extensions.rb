module Trax
  module Model
    module StructExtensions
      extend ::ActiveSupport::Concern
      include ::ActiveModel::Validations

      included do
        attr_reader :record
      end

      def inspect
        self.to_hash.inspect
      end

      def to_json
        self.to_hash.to_json
      end

      def value
        self
      end

      module ClassMethods
        #bit of a hack for the sake of strong params for now
        def permitted_keys
          @permitted_keys ||= properties.map(&:to_sym)
        end

        def define_model_scopes_for(*attribute_names)
          attribute_names.each do |attribute_name|
            define_model_scope_for(attribute_name)
          end
        end

        def define_model_scope_for(attribute_name, **options)
          attribute_klass = fields[attribute_name]

          case fields[attribute_name].type
          when :boolean
            define_where_scopes_for_boolean_property(attribute_name, attribute_klass, **options)
          when :enum
            define_scopes_for_enum(attribute_name, attribute_klass, **options)
          when :array
            define_scopes_for_array(attribute_name, attribute_klass, **options)
          when :integer
            define_scopes_for_numeric(attribute_name, attribute_klass, **options)
          when :time
            define_scopes_for_time(attribute_name, attribute_klass, **options)
          else
            define_where_scopes_for_property(attribute_name, attribute_klass, **options)
          end
        end

        def define_scopes_for_array(attribute_name, property_klass, as:nil)
          return unless has_active_record_ancestry?(property_klass)

          model_class = model_class_for_property(property_klass)
          field_name = property_klass.parent_definition.name.demodulize.underscore
          attribute_name = property_klass.name.demodulize.underscore
          scope_name = as || :"by_#{field_name}_#{attribute_name}"
          model_class.scope(scope_name, lambda{ |*_scope_values|
            _scope_values.flat_compact_uniq!

            #todo: HACK, due to AR. Correct way of doing it would be this:
            # model_class.where("#{field_name} -> '#{attribute_name}' ?| array[?]", *_scope_values)
            # but we can't, because it treats the first ? as a bind variable as well

            sanitized_prepared_scope_values = ::ActiveRecord::Base.__send__(:sanitize_sql, _scope_values.to_single_quoted_list, '')
            model_class.where("#{field_name} -> '#{attribute_name}' ?| array[#{sanitized_prepared_scope_values}]")
          })
        end

        def define_scopes_for_numeric(attribute_name, property_klass, as:nil)
          return unless has_active_record_ancestry?(property_klass)

          model_class = model_class_for_property(property_klass)
          field_name = property_klass.parent_definition.name.demodulize.underscore
          attribute_name = property_klass.name.demodulize.underscore
          cast_type = property_klass.type

          { :gt => '>', :gte => '>=', :lt => '<', :lte => '<=', :eq => '='}.each_pair do |k, operator|
            scope_name = as ? :"#{as}_#{k}" : :"by_#{field_name}_#{attribute_name}_#{k}"

            model_class.scope(scope_name, lambda{ |*_scope_values|
              _scope_values.flat_compact_uniq!
              model_class.where("(#{field_name} ->> '#{attribute_name}')::#{cast_type} #{operator} ?", _scope_values)
            })
          end
        end

        def define_scopes_for_time(attribute_name, property_klass, as:nil)
          return unless has_active_record_ancestry?(property_klass)

          model_class = model_class_for_property(property_klass)
          field_name = property_klass.parent_definition.name.demodulize.underscore
          attribute_name = property_klass.name.demodulize.underscore
          cast_type = 'timestamp'

          { :gt => '>', :lt => '<'}.each_pair do |k, operator|
            scope_prefix = as ? as : :"by_#{field_name}_#{attribute_name}"
            scope_name = "#{scope_prefix}_#{k}"
            scope_alias = "#{scope_prefix}_#{{:gt => 'after', :lt => 'before' }[k]}"

            model_class.scope(scope_name, lambda{ |*_scope_values|
              _scope_values.flat_compact_uniq!
              model_class.where("(#{field_name} ->> '#{attribute_name}')::#{cast_type} #{operator} ?", _scope_values)
            })
            model_class.singleton_class.__send__("alias_method", scope_alias.to_sym, scope_name)
          end
        end

        #this only supports properties 1 level deep, but works beautifully
        #I.E. for this structure
        # define_attributes do
        #   struct :custom_fields do
        #     enum :color, :default => :blue do
        #       define :blue,     1
        #       define :red,      2
        #       define :green,    3
        #     end
        #   end
        # end
        # ::Product.by_custom_fields_color(:blue, :red)
        # will return #{Product color=blue}, #{Product color=red}
        def define_scopes_for_enum(attribute_name, enum_klass, as:nil)
          return unless has_active_record_ancestry?(enum_klass)

          model_class = model_class_for_property(enum_klass)
          field_name = enum_klass.parent_definition.name.demodulize.underscore
          attribute_name = enum_klass.name.demodulize.underscore
          scope_name = as || :"by_#{field_name}_#{attribute_name}"
          model_class.scope(scope_name, lambda{ |*_scope_values|
            _integer_values = enum_klass.select_values(*_scope_values.flat_compact_uniq!)
            _integer_values.map!(&:to_s)
            model_class.where("#{field_name} -> '#{attribute_name}' IN(?)", _integer_values)
          })
        end

        def define_where_scopes_for_boolean_property(attribute_name, property_klass, as:nil)
          return unless has_active_record_ancestry?(property_klass)

          model_class = model_class_for_property(property_klass)
          field_name = property_klass.parent_definition.name.demodulize.underscore
          attribute_name = property_klass.name.demodulize.underscore
          scope_name = as || :"by_#{field_name}_#{attribute_name}"
          model_class.scope(scope_name, lambda{ |*_scope_values|
            _scope_values.map!(&:to_s).flat_compact_uniq!
            model_class.where("#{field_name} -> '#{attribute_name}' IN(?)", _scope_values)
          })
        end

        def define_where_scopes_for_property(attribute_name, property_klass, as:nil)
          return unless has_active_record_ancestry?(property_klass)

          model_class = model_class_for_property(property_klass)
          field_name = property_klass.parent_definition.name.demodulize.underscore
          attribute_name = property_klass.name.demodulize.underscore
          scope_name = as || :"by_#{field_name}_#{attribute_name}"

          model_class.scope(scope_name, lambda{ |*_scope_values|
            _scope_values.map!(&:to_s).flat_compact_uniq!
            model_class.where("#{field_name} ->> '#{attribute_name}' IN(?)", _scope_values)
          })
        end

        def has_active_record_ancestry?(property_klass)
          return false unless property_klass.respond_to?(:parent_definition)

          result = if property_klass.parent_definition.ancestors.include?(::ActiveRecord::Base)
            true
          else
            has_active_record_ancestry?(property_klass.parent_definition)
          end

          result
        end

        def model_class_for_property(property_klass)
          result = if property_klass.parent_definition.ancestors.include?(::ActiveRecord::Base)
            property_klass.parent_definition
          else
            model_class_for_property(property_klass.parent_definition)
          end

          result
        end
      end
    end
  end
end
