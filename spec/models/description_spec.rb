# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Description, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to define_enum_for(:category).with(Description.categories.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:describable) }
  end

  it 'factory can produce a valid model' do
    model = create(:data_management_plan_description)
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Describable'
    model = create(:dataset_description)
    expect(model.valid?).to eql(true), 'expected Dataset to be Describable'
    model = create(:project_description)
    expect(model.valid?).to eql(true), 'expected Project to be Describable'
  end

  context 'scopes' do
    before(:each) do
      @json = {
        'created_at': Time.now.to_s,
        'links': [{ 'rel': 'self', 'href': 'http://localhost:3000/descriptions/1' }],
        'category': Description.categories.keys.sample,
        'value': Faker::Lorem.word
      }
    end

    describe 'from_json' do
      it 'converts the expected json into an Identifier model' do
        desc = Description.from_json(@json)
        expect(desc.created_at.to_s).not_to eql(@json[:created_at])
        expect(desc.category).to eql(@json[:category])
        expect(desc.value).to eql(@json[:value])
      end
    end
  end

end
