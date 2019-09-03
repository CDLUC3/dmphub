# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:data_management_plans) }
  end

  it 'factory can produce a valid model' do
    model = create(:person)
    expect(model.valid?).to eql(true)
  end
end
