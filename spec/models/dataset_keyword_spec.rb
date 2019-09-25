# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatasetKeyword, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to belong_to(:keyword) }
  end
end
