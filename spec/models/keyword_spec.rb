# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keyword, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:value) }
    it 'validates uniqueness of value' do
      subject = create(:keyword)
      expect(subject).to validate_uniqueness_of(:value).case_insensitive
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:datasets) }
  end

  it 'factory can produce a valid model' do
    model = create(:keyword)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'deletes the dataset_keyword' do
      dataset = create(:dataset)
      model = create(:keyword)
      dataset.keywords << model
      dataset.save
      model.destroy
      expect(DatasetKeyword.last).to eql(nil)
      dataset.reload
      expect(dataset.keywords.empty?).to eql(true)
    end
  end
end
