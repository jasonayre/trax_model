module Trax
  module Model
    module Mixins
      extend ::ActiveSupport::Autoload

      autoload :CachedFindBy
      autoload :CachedMethods
      autoload :CachedRelations
      autoload :FieldScopes
      autoload :Freezable
      autoload :IdScopes
      autoload :Restorable
      autoload :RelationScopes
      autoload :SortScopes
      autoload :StiEnum
      autoload :UniqueId
    end
  end
end
