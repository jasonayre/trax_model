#primitive/trax core type extensions
module Trax
  module Model
    module ExtensionsFor
      extend ::ActiveSupport::Autoload

      autoload :Base
      autoload :Enumerable
      autoload :Struct
      autoload :String
    end
  end
end
