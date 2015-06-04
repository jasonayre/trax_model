module Trax
  module Model
    module Mixins
      module FieldScopes
        extend ::Trax::Model::Mixin

        after_included do |**options|
          options.each_pair do |field_scope_name, field_scope_options|
            field_scope_options = {} if [ true, false ].include?(field_scope_options)

            field_scope_options[:field_name] ||= (field_scope_name.to_s.include?("by_") ? field_scope_name.to_s.split("by_").shift.to_sym : field_scope_name)
            field_scope_options[:type] ||= :where

            raise ::Trax::Model::Errors::FieldDoesNotExist.new(
              :field_name => field_scope_options[:field_name]
            ) unless column_names.include?(field_scope_options[:field_name])

            __send__("define_#{field_scope_options[:type]}_scope_for_field", **field_scope_options)
          end
        end

        def self.define_where_scope_for_field(field_scope_name, **options)
          scope options[:field_name], lambda{ |*_record_ids|
            _record_ids.flat_compact_uniq!
            where(options[:field_name] => _record_ids)
          }
        end
      end
    end
  end
end
