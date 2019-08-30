# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }

    it 'should validate that :value is unique per :category' do
      person = create(:person)
      identifier = create(:identifier, category: Identifier.categories.keys.sample, identifiable: person)
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category).case_insensitive
        .with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }
  end
end
