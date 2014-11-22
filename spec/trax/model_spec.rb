require 'spec_helper'

describe ::Trax::Model do
  subject do
    ::Product.class_eval do
      include ::Trax::Model
    end
  end

  its(:whatever) { should be_a(::Hashie::Mash) }
end
