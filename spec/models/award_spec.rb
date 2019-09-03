# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Award, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:funder_uri) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:award_statuses) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:award)
    expect(model.valid?).to eql(true)
  end
end
