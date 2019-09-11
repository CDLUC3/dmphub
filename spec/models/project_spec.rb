# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_on) }
    it { is_expected.to validate_presence_of(:end_on) }
  end

  context 'associations' do
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:awards) }
  end

  it 'factory can produce a valid model' do
    model = create(:project)
    expect(model.valid?).to eql(true)
  end
end
