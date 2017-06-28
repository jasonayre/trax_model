require 'spec_helper'

describe ::Trax::Model::Validators do
  describe "RegisterValidator" do
    it { expect(::ActiveRecord::Base).to respond_to(:validates_associated_with_bubbling) }
  end
end
