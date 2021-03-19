# frozen_string_literal: true

# == Schema Information
#
# Table name: hosts
#
#  id                  :bigint           not null, primary key
#  title               :string(255)      not null
#  description         :text(4294967295)
#  supports_versioning :boolean
#  backup_type         :string(255)
#  backup_frequency    :string(255)
#  storage_type        :string(255)
#  availability        :string(255)
#  geo_location        :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  certified_with      :text(65535)
#  pid_system          :text(65535)
#  provenance_id       :bigint
#
require 'rails_helper'

RSpec.describe Host, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to have_many(:distributions) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:host)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the distribution' do
      distribution = create(:distribution)
      model = create(:host, distributions: [distribution])
      model.destroy
      expect(Distribution.last).to eql(distribution)
    end
    it 'deletes associated identifiers' do
      model = create(:host, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end
end
