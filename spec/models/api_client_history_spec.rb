# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_histories
#
#  id                      :bigint           not null, primary key
#  api_client_id           :bigint           not null
#  data_management_plan_id :bigint           not null
#  change_type             :integer
#  description             :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'rails_helper'

RSpec.describe ApiClientHistory, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to define_enum_for(:change_type).with_values(%w[add edit archive embargo]) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:api_client) }
    it { is_expected.to belong_to(:data_management_plan) }
  end
end
