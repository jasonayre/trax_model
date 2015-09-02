module Trax
  module Model
    module Attributes
      class Attribute
        #should be an abstract class attribute, but making it a normal
        #class attribute for now until https://github.com/jruby/jruby/issues/3096
        class_attribute :type
      end
    end
  end
end
