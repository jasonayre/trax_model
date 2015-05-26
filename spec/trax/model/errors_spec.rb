require 'spec_helper'

describe ::Trax::Model::Errors do
  subject{ Trax::Model::Errors::InvalidPrefix }

  it do
    expect{subject.new(:blah => "blah")}.to raise_error
  end
end
