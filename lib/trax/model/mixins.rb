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
      autoload :SortScopes
      autoload :StiEnum
      autoload :UniqueId
    end
  end
end
