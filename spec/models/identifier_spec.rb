# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }

    it 'should validate that :value is unique per :category' do
      create(:identifier, category: Identifier.categories.keys.sample, identifiable: create(:person))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category).case_insensitive
                                                   .with_message('has already been taken')
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
end
