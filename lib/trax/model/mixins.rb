module Trax
  module Model
    module Mixins
      extend ::ActiveSupport::Autoload

      autoload :FieldScopes
      autoload :IdScopes
      autoload :SortByScopes
      autoload :StiEnum
    end
  end
end
