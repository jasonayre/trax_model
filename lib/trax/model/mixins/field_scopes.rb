module Trax
  module Model
    module Mixins
      module FieldScopes
        extend ::Trax::Model::Mixin

        mixed_in do |**options|
          options.each_pair do |field_scope_name, field_scope_options|
            field_scope_options = {} if [ true, false ].include?(field_scope_options)

            field_scope_options[:field] ||= field_scope_name.to_s.include?("by_") ? field_scope_name.to_s.split("by_").pop.to_sym : field_scope_name
            field_scope_options[:type] ||= :where

            raise ::Trax::Model::Errors::FieldDoesNotExist.new(
              :field => field_scope_options[:field],
              :model => self
            ) unless column_names.include?(field_scope_options[:field].to_s)

            case field_scope_options[:type]
            when :where
              define_where_scope_for_field(field_scope_name, **field_scope_options)
            when :match
              define_matching_scope_for_field(field_scope_name, **field_scope_options)
            when :matching
              define_matching_scope_for_field(field_scope_name, **field_scope_options)
            when :not
              define_where_not_scope_for_field(field_scope_name, **field_scope_options)
            when :where_not
              define_where_not_scope_for_field(field_scope_name, **field_scope_options)
            else
              define_where_scope_for_field(field_scope_name, **field_scope_options)
            end
          end
        end

        module ClassMethods
          private
          def define_where_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _values.flat_compact_uniq!
              where(options[:field] => _values)
            }
          end

          def define_where_not_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _values.flat_compact_uniq!
              where.not(options[:field] => _values)
            }
          end

          def define_matching_scope_for_field(field_scope_name, **options)
            scope field_scope_name, lambda{ |*_values|
              _values.flat_compact_uniq!
              matching(options[:field] => _values)
            }
          end
        end
      end
    end
  end
end
