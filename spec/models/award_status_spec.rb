# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AwardStatus, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to define_enum_for(:status).with(AwardStatus.statuses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:award) }
  end
end
