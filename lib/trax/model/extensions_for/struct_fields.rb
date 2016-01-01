module Trax
  module Model
    module ExtensionsFor
      module StructFields
        extend ::ActiveSupport::Autoload

        autoload :Float
        autoload :Numeric
        autoload :Time

        def self.[](val)
          "#{name}::#{val.to_s.classify}".safe_constantize
        end
      end
    end
  end
end
