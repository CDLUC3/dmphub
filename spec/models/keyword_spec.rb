# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keyword, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:value) }
  end

  context 'associations' do
    it { is_expected.to have_many(:datasets) }
  end

  it 'factory can produce a valid model' do
    model = create(:keyword)
    expect(model.valid?).to eql(true)
  end

end
