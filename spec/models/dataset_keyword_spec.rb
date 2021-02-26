# frozen_string_literal: true

# == Schema Information
#
# Table name: datasets_keywords
#
#  id         :bigint           not null, primary key
#  dataset_id :bigint
#  keyword_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe DatasetKeyword, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to belong_to(:keyword) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:dataset) }
    it { is_expected.to validate_presence_of(:keyword) }
  end

  describe 'cascading deletes' do
    before(:each) do
      @dataset = create(:dataset)
      @keyword = create(:keyword)
      @model = DatasetKeyword.create(dataset: @dataset, keyword: @keyword)
      @model.destroy
    end

    it 'does not delete the dataset' do
      expect(Dataset.last).to eql(@dataset)
    end
    it 'does not delete the keyword' do
      expect(Keyword.last).to eql(@keyword)
    end
  end
end
