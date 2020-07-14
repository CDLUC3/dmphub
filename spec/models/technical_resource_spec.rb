# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TechnicalResource, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dataset).optional }
  end

  it 'factory can produce a valid model' do
    model = create(:technical_resource)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:technical_resource, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
  end
end
