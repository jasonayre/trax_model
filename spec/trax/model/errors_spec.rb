require 'spec_helper'

describe ::Trax::Model::Errors do
  subject{ Trax::Model::Errors::InvalidPrefix }

  it do
    expect{raise subject.new("blah")}.to raise_error(subject, /blah/)
  end

end
