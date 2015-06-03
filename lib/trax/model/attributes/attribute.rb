module Trax
  module Model
    module Attributes
      class Attribute
        include ::Trax::Core::AbstractMethods

        abstract_class_attribute :type
      end
    end
  end
end
