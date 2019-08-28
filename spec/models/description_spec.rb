# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Description, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to define_enum_for(:category).with(Description.categories.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:describable) }
  end
end
