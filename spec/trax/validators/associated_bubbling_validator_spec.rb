require 'spec_helper'

describe ::Trax::Model::Validators::AssociatedBubblingValidator do
  subject { ::AssociatedBubblingThing.create(:name => "whatever") }

  it {
    subject.build_associated_bubbling_related_thing
    expect(subject.valid?).to eq false
    expect(subject.errors.to_hash.keys.first).to eq :associated_bubbling_related_thing
    expect(subject.errors.to_hash.values.first).to eq ["Name can't be blank"]
  }
end
