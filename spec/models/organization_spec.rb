# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:organization)
    expect(model.valid?).to eql(true)
  end
end
