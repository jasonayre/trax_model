require 'spec_helper'

describe ::Trax::Model::Mixins::FieldScopes do
  let(:known_title) { "Whatever's Clever: The Questioning" }
  let(:other_known_title) { "Whatever's Clever: The Reckoning" }
  let(:unknown_title) { "Most Known Unkown" }
  let(:known_titles) { [known_title, other_known_title] }
  let!(:known_message) { ::Message.create(:title => known_title) }
  let!(:other_known_message) { ::Message.create(:title => other_known_title) }
  let!(:known_titles_relation) { ::Message.where(id: known_message.id).select(:title) }
  let!(:known_titles_downcased_relation) { ::Message.where(id: known_message.id).select('lower(title)') }
  let!(:known_titles_upcased_relation) { ::Message.where(id: known_message.id).select('upper(title)') }

  subject { ::Message }

  context "type 'where'" do
    it { expect(subject.by_title(known_title)).to be_present }
    it { expect(subject.by_title(known_title.downcase)).to be_empty }
    it { expect(subject.by_title(known_title.upcase)).to be_empty }

    it { expect(subject.by_title(*known_titles)).to be_present }
    it { expect(subject.by_title(*known_titles.map(&:downcase))).to be_empty }
    it { expect(subject.by_title(*known_titles.map(&:upcase))).to be_empty }

    it { expect(subject.by_title(known_titles_relation)).to be_present }
    it { expect(subject.by_title(known_titles_downcased_relation)).to be_empty }
    it { expect(subject.by_title(known_titles_upcased_relation)).to be_empty }

    it { expect(subject.by_title(unknown_title)).to be_empty }
  end

  context "type 'where_lower'" do
    it { expect(subject.by_title_case_insensitive(known_title)).to be_present }
    it { expect(subject.by_title_case_insensitive(known_title.downcase)).to be_present }
    it { expect(subject.by_title_case_insensitive(known_title.upcase)).to be_present }

    it { expect(subject.by_title_case_insensitive(*known_titles)).to be_present }
    it { expect(subject.by_title_case_insensitive(*known_titles.map(&:downcase))).to be_present }
    it { expect(subject.by_title_case_insensitive(*known_titles.map(&:upcase))).to be_present }

    it { expect(subject.by_title_case_insensitive(known_titles_relation)).to be_empty }
    it { expect(subject.by_title_case_insensitive(known_titles_downcased_relation)).to be_present }
    it { expect(subject.by_title_case_insensitive(known_titles_upcased_relation)).to be_empty }

    it { expect(subject.by_title_case_insensitive(unknown_title)).to be_empty }
  end
end
