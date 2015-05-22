module Trax
  module Model
    module Mixins
      module SortByScopes
        extend ::Trax::Model::Mixin

        included do
          scope :sort_by_most_recent, lambda{|field_name='created_at'|
            order("#{field_name} ASC")
          }
          scope :sort_by_least_recent, lambda{|field_name='created_at'|
            order("#{field_name} DESC")
          }
          
          class << self
            alias_method :sort_by_newest, :sort_by_most_recent
            alias_method :sort_by_oldest, :sort_by_least_recent
            alias_method :by_newest, :sort_by_most_recent
            alias_method :by_oldest, :sort_by_least_recent
          end
        end
      end
    end
  end
end
