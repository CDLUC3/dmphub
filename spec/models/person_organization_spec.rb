# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonOrganization, type: :model do

  context 'associations' do
    it { is_expected.to belong_to(:person) }
    it { is_expected.to belong_to(:organization) }
  end

end
