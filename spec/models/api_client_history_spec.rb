# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClientHistory, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to define_enum_for(:type).with(%w[add edit archive embargo]) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:api_client) }
    it { is_expected.to belong_to(:data_management_plan) }
  end
end
