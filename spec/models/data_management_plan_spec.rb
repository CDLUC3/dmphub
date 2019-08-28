# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:language) }
    it { is_expected.to validate_presence_of(:ethical_issues) }
    it { is_expected.to validate_length_of(:datasets) }
  end

  context 'associations' do
    it { is_expected.to have_many(:descriptions) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:datasets) }
    it { is_expected.to belong_to(:project) }
  end
end