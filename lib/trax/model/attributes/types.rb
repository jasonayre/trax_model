module Trax
  module Model
    module Attributes
      module Types
        ::Trax::Core::FS::CurrentDirectory.new['types'].recursive_files.each do |file|
          load file
        end
      end
    end
  end
end
