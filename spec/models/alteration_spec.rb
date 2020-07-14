# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alteration, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:provenance) }
    it { is_expected.to belong_to(:alterable) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:provenance) }
    it { is_expected.to validate_presence_of(:change_log) }
  end
end
