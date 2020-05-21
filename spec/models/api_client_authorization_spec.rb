# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClientAuthorization, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:api_client) }
    it { is_expected.to belong_to(:authorizable) }
  end
end
