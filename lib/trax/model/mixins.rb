module Trax
  module Model
    module Mixins
      extend ::ActiveSupport::Autoload

      autoload :CachedFindBy
      autoload :CachedRelations
      autoload :FieldScopes
      autoload :Freezable
      autoload :IdScopes
      autoload :Restorable
      autoload :SortByScopes
      autoload :StiEnum
      autoload :UniqueId
    end
  end
end
