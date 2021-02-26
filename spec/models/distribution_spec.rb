# frozen_string_literal: true

# == Schema Information
#
# Table name: distributions
#
#  id              :bigint           not null, primary key
#  dataset_id      :bigint
#  title           :string(255)      not null
#  description     :text(4294967295)
#  format          :string(255)
#  byte_size       :float(24)
#  access_url      :string(255)
#  download_url    :string(255)
#  data_access     :integer
#  available_until :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provenance_id   :bigint
#  host_id         :bigint
#
require 'rails_helper'

RSpec.describe Distribution, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to define_enum_for(:data_access).with_values(Distribution.data_accesses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset).optional }
    it { is_expected.to have_many(:licenses) }
    it { is_expected.to have_one(:host) }
  end

  it 'factory can produce a valid model' do
    model = create(:distribution)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:distribution, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
    it 'deletes associated licenses' do
      license = create(:license)
      ident = license.id
      model = create(:distribution, licenses: [license])
      model.destroy
      expect(License.where(id: ident).empty?).to eql(true)
    end
    it 'deletes associated host' do
      host = create(:host)
      ident = host.id
      model = create(:distribution, host: host)
      model.destroy
      expect(Host.where(id: ident).empty?).to eql(true)
    end
  end
end
