# frozen_string_literal: true

# == Schema Information
#
# Table name: alterations
#
#  id             :bigint           not null, primary key
#  alterable_id   :bigint           not null
#  alterable_type :string(255)      default(""), not null
#  change_log     :text(65535)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  provenance_id  :bigint           not null
#
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
