# frozen_string_literal: true

# == Schema Information
#
# Table name: technical_resources
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string(255)      not null
#  provenance_id :bigint
#
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
