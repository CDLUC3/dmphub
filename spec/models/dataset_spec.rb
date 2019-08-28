# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:dataset_type) }
  end

  context 'associations' do
    it { is_expected.to have_many(:descriptions) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to belong_to(:data_management_plan) }
  end
end
