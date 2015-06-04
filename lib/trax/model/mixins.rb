module Trax
  module Model
    module Mixins
      extend ::ActiveSupport::Autoload

      autoload :FieldScopes
      autoload :IdScopes
      autoload :SortByScopes
    end
  end
end
