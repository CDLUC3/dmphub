# frozen_string_literal: true

# == Schema Information
#
# Table name: datasets
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  dataset_type            :integer          default("audiovisual"), not null
#  personal_data           :boolean
#  sensitive_data          :boolean
#  description             :text(4294967295)
#  publication_date        :datetime
#  language                :string(255)
#  data_quality_assurance  :text(4294967295)
#  preservation_statement  :text(4294967295)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
require 'rails_helper'

RSpec.describe Dataset, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:dataset_type) }
    it { is_expected.to define_enum_for(:dataset_type).with_values(Dataset.dataset_types.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan).optional }
    it { is_expected.to have_many(:keywords) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:security_privacy_statements) }
    it { is_expected.to have_many(:technical_resources) }
    it { is_expected.to have_many(:metadata) }
    it { is_expected.to have_many(:distributions) }
  end

  it 'factory can produce a valid model' do
    model = create(:dataset)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the data_management_plan' do
      dmp = create(:data_management_plan, project: create(:project))
      model = create(:dataset, data_management_plan: dmp)
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
    xit 'does not delete associated keywords' do
      # TODO: Fix asfter we figure out why it wants :provenance
      keyword = create(:keyword)
      model = create(:dataset, keywords: [keyword])
      model.destroy
      expect(Keyword.where(id: keyword.id).first).to eql(keyword)
    end
    it 'deletes associated security_privacy_statements' do
      stmt = create(:security_privacy_statement)
      model = create(:dataset, security_privacy_statements: [stmt])
      model.destroy
      expect(SecurityPrivacyStatement.where(id: stmt.id).empty?).to eql(true)
    end
    it 'deletes associated technical_resources' do
      resource = create(:technical_resource)
      model = create(:dataset, technical_resources: [resource])
      model.destroy
      expect(TechnicalResource.where(id: resource.id).empty?).to eql(true)
    end
    it 'deletes associated metadata' do
      datum = create(:metadatum)
      model = create(:dataset, metadata: [datum])
      model.destroy
      expect(Metadatum.where(id: datum.id).empty?).to eql(true)
    end
    it 'deletes associated distributions' do
      distro = create(:distribution)
      model = create(:dataset, distributions: [distro])
      model.destroy
      expect(Distribution.where(id: distro.id).empty?).to eql(true)
    end
    it 'deletes associated identifiers' do
      model = create(:dataset, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end
end
