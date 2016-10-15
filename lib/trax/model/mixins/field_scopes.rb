module Trax
  module Model
    module Mixins
      module FieldScopes
        extend ::Trax::Model::Mixin

        mixed_in do |**options|
          options.each_pair do |field_scope_name, field_scope_options|
            field_scope(field_scope_name, field_scope_options)
          end
        end

        module ClassMethods
          def field_scope(field_scope_name, field_scope_options)
            field_scope_options = {} if [ true, false ].include?(field_scope_options)

            field_scope_options[:field] ||= field_scope_name.to_s.include?("by_") ? field_scope_name.to_s.split("by_").pop.to_sym : field_scope_name
            field_scope_options[:type] ||= :where

            case field_scope_options[:type]
            when :where
              define_where_scope_for_field(field_scope_name, **field_scope_options)
            when :where_lower
              define_where_lower_scope_for_field(field_scope_name, **field_scope_options)
            when :match, :matching
              define_matching_scope_for_field(field_scope_name, **field_scope_options)
            when :where_not, :not
              define_where_not_scope_for_field(field_scope_name, **field_scope_options)
            else
              define_where_scope_for_field(field_scope_name, **field_scope_options)
            end
          end

          private
          def define_where_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _relation = if _values.first.is_a?(::ActiveRecord::Relation)
                where(options[:field] => _values.first)
              else
                _values.flat_compact_uniq!
                where(options[:field] => _values)
              end

              _relation
            }

            # Alias scope names with pluralized versions, i.e. by_id also => by_ids
            singleton_class.__send__(:alias_method, :"#{field_scope_name.to_s.pluralize}", field_scope_name)
          end

          def define_where_lower_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _query = "lower(#{options[:field]}) in (?)"

              _relation = if _values.first.is_a?(::ActiveRecord::Relation)
                where(_query, _values.first)
              else
                _values.flat_compact_uniq!.map!(&:downcase)
                where(_query, _values)
              end

              _relation
            }

            # Alias scope names with pluralized versions, i.e. by_id also => by_ids
            singleton_class.__send__(:alias_method, :"#{field_scope_name.to_s.pluralize}", field_scope_name)
          end

          def define_where_not_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _relation = if _values.first.is_a?(::ActiveRecord::Relation)
                where.not(options[:field] => _values.first)
              else
                _values.flat_compact_uniq!
                where.not(options[:field] => _values)
              end

              _relation
            }
          end

          def define_matching_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _relation = if _values.first.is_a?(::ActiveRecord::Relation)
                matching(options[:field] => _values.first)
              else
                _values.flat_compact_uniq!
                matching(options[:field] => _values)
              end

              _relation
            }
          end
        end
      end
    end
  end
end
