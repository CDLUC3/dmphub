# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadatum, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:language) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
  end

  it 'factory can produce a valid model' do
    model = create(:metadatum)
    expect(model.valid?).to eql(true)
  end
end
