# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:provenance) }
    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }

    it 'should validate that :value is unique per :category+:provenance' do
      create(:identifier, category: Identifier.categories.keys.sample, identifiable: create(:person))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category, :provenance)
                                                   .case_insensitive.with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }
  end

  it 'factory can produce a valid model' do
    model = create(:award_identifier)
    expect(model.valid?).to eql(true), 'expected Award to be Identifiable'
    model = create(:data_management_plan_identifier)
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Identifiable'
    model = create(:dataset_identifier)
    expect(model.valid?).to eql(true), 'expected Dataset to be Identifiable'
    model = create(:person_identifier)
    expect(model.valid?).to eql(true), 'expected Person to be Identifiable'
  end

  context 'scopes' do
    before(:each) do
      @json = {
        'created_at': Time.now.to_s,
        'category': Identifier.categories.keys.sample,
        'provenance': Faker::Lorem.word,
        'value': Faker::Lorem.word
      }
    end

    describe 'from_json' do
      it 'converts the expected json into an Identifier model' do
        identifier = Identifier.from_json(@json)
        expect(identifier.created_at.to_s).not_to eql(@json[:created_at])
        expect(identifier.category).to eql(@json[:category])
        expect(identifier.provenance).to eql(@json[:provenance])
        expect(identifier.value).to eql(@json[:value])
      end
    end
  end

end
