# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:organizations) }
  end

  it 'factory can produce a valid model' do
    model = create(:person)
    expect(model.valid?).to eql(true)
  end

  context 'scopes' do
    before(:each) do
      @json = {
        'created_at': Time.now.to_s,
        'name': Faker::Movies::StarWars.name,
        'identifiers': [{ 'category': 'orcid', 'provenance': 'orcid', 'value': 'abcd', 'created_at': Time.now}],
        'mbox': 'weird.test@example.org'
      }
    end

    describe 'from_json' do
      it 'converts the expected json into an Identifier model' do
        person = Person.from_json(@json, Faker::Lorem.word)
        expect(person.created_at.to_s).not_to eql(@json[:created_at])
        expect(person.name).to eql(@json[:name])
        expect(person.identifiers.length).to eql(2)
      end
    end
  end

end
