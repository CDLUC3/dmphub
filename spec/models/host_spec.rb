# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Host, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution).optional }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:host)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the distribution' do
      distribution = create(:distribution)
      model = create(:host, distribution: distribution)
      model.destroy
      expect(Distribution.last).to eql(distribution)
    end
    it 'deletes associated identifiers' do
      model = create(:host, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end
end
