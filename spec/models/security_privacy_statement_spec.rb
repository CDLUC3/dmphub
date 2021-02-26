# frozen_string_literal: true

# == Schema Information
#
# Table name: security_privacy_statements
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  title         :string(255)      not null
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provenance_id :bigint
#
require 'rails_helper'

RSpec.describe SecurityPrivacyStatement, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset).optional }
  end

  it 'factory can produce a valid model' do
    model = create(:security_privacy_statement)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:security_privacy_statement, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
  end
end
