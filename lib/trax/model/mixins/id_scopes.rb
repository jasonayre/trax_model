module Trax
  module Model
    module Mixins
      module IdScopes
        extend ::Trax::Model::Mixin

        included do
          scope :by_id, lambda{ |*ids|
            where(:id => ids.flatten.compact.uniq)
          }
          scope :by_id_is_not, lambda{ |*ids|
            where.not(:id => ids.flatten.compact.uniq)
          }

          class << self
            alias_method :by_ids, :by_id
            alias_method :by_ids_are_not, :by_id_is_not
          end
        end
      end
    end
  end
end
