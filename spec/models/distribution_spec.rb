# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Distribution, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to have_many(:licenses) }
    it { is_expected.to have_many(:hosts) }
  end

  it 'factory can produce a valid model' do
    model = create(:distribution)
    expect(model.valid?).to eql(true)
  end
end
