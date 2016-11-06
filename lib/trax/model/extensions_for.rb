#trax model attribute dsl/trax core type extensions
module Trax
  module Model
    module ExtensionsFor
      extend ::ActiveSupport::Autoload

      autoload :Array
      autoload :Base
      autoload :Boolean
      autoload :Enum
      autoload :Enumerable
      autoload :Integer
      autoload :Numeric
      autoload :Set
      autoload :Struct
      autoload :StructFields
      autoload :String
    end
  end
end
