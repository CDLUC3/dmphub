# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Host, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:host)
    expect(model.valid?).to eql(true)
  end
end