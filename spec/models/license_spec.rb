# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:license_ref) }
    it { is_expected.to validate_presence_of(:start_date) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution).optional }
  end

  it 'factory can produce a valid model' do
    model = create(:license)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the distribution' do
      distro = create(:distribution)
      model = create(:license, distribution: distro)
      model.destroy
      expect(Distribution.last).to eql(distro)
    end
  end
end
