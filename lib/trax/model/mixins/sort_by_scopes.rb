module Trax
  module Model
    module Mixins
      module SortByScopes
        extend ::Trax::Model::Mixin

        SORT_DIRECTIONS = [ "asc", "desc" ].freeze

        included do
          scope :order_by_lower, lambda{|field_name, dir='ASC', model=self|
            field = model.arel_table[field_name]
            order_relation = ::Arel::Nodes::SqlLiteral.new(field.lower.to_sql).__send__(dir.to_s.downcase)
            order(order_relation)
          }
          scope :order_by, lambda{|field_name, dir='ASC', model=self|
            field = model.arel_table[field_name].__send__(dir.to_s.downcase)
            all.order(field)
          }
          scope :sort_by_most_recent, lambda{|field_name='created_at'|
            order("#{field_name} DESC")
          }
          scope :sort_by_least_recent, lambda{|field_name='created_at'|
            order("#{field_name} ASC")
          }

          class << self
            alias_method :sort_by_newest, :sort_by_most_recent
            alias_method :sort_by_oldest, :sort_by_least_recent
            alias_method :by_newest, :sort_by_most_recent
            alias_method :by_oldest, :sort_by_least_recent
          end

          module ClassMethods
            def sort_scope(field_name, **options)
              define_order_by_scope_for_field(field_name, **options)
            end

            def define_order_by_scope_for_field(field_name, as:field_name, class_name:self.name, prefix:'sort_by', **options)
              klass = class_name.is_a?(String) ? class_name.constantize : class_name
              column_type = klass.column_types[field_name.to_s].type

              case column_type
              when :string
                define_order_by_lower_scope_for_field(field_name, as:as, prefix:prefix, model: klass)
              else
                SORT_DIRECTIONS.each do |dir|
                  scope :"#{prefix}_#{as}_#{dir}", lambda{|*args|
                    order_by(field_name, dir, klass)
                  }
                end
              end
            end

            def define_order_by_scope_for_string_field(field_name, **options)
              define_order_by_lower_scope_for_field(field_name)
            end

            def define_order_by_lower_scope_for_field(field_name, as:, model:, prefix:'sort_by')
              SORT_DIRECTIONS.each do |dir|
                scope :"#{prefix}_#{as}_#{dir}", lambda{|*args|
                  order_by_lower(field_name, dir, model)
                }
              end
            end
          end
        end
      end
    end
  end
end
