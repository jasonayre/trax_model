::String.class_eval do
  def uuid
    self.length == 36 ? ::Trax::Model::UUID.new(self) : nil
  end
end
