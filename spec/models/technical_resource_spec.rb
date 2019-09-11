# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TechnicalResource, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:technical_resource)
    expect(model.valid?).to eql(true)
  end
end
