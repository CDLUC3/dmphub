# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadatum, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:language) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset).optional }
  end

  it 'factory can produce a valid model' do
    model = create(:metadatum)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:metadatum, :complete, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
    it 'deletes associated identifiers' do
      model = create(:metadatum, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end
end
