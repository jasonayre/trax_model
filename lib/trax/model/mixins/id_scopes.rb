#note this only works with postgres UUID column Types

module Trax
  module Model
    module Mixins
      module IdScopes
        extend ::Trax::Model::Mixin

        included do
          if table_exists?
            id_column_names = self.columns.select{ |col| col.sql_type == "uuid" }.map(&:name).map(&:to_sym)
            id_column_names.each do |_id_column_name|
              scope :"by_#{_id_column_name}", lambda{ |*_record_ids|
                _record_ids.flat_compact_uniq!
                where(_id_column_name => _record_ids)
              }

              scope :"by_#{_id_column_name}_not", lambda{ |*_record_ids|
                _record_ids.flat_compact_uniq!
                where.not(_id_column_name => _record_ids)
              }

              define_singleton_method(:"by_#{_id_column_name}s") do |*_record_ids|
                __send__("by_#{_id_column_name}", _record_ids)
              end

              define_singleton_method(:"by_#{_id_column_name}s_not") do |*_record_ids|
                __send__("by_#{_id_column_name}_not", _record_ids)
              end
            end
          end
        end
      end
    end
  end
end
