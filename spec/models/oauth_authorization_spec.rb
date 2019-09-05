# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OauthAuthorization, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:oauth_application) }
    it { is_expected.to validate_presence_of(:data_management_plan) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:oauth_application) }
    it { is_expected.to belong_to(:data_management_plan) }
  end

  it 'factory can produce a valid model' do
    model = create(:oauth_authorization)
    expect(model.valid?).to eql(true)
  end
end
