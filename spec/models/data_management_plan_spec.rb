# frozen_string_literal: true

# == Schema Information
#
# Table name: data_management_plans
#
#  id                         :bigint           not null, primary key
#  title                      :string(255)      not null
#  language                   :string(255)      not null
#  ethical_issues             :boolean
#  description                :text(4294967295)
#  ethical_issues_description :text(4294967295)
#  ethical_issues_report      :text(4294967295)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  project_id                 :bigint
#  provenance_id              :bigint
#
require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:contributors) }
    it { is_expected.to have_many(:costs) }
    it { is_expected.to have_many(:datasets) }
    it { is_expected.to have_many(:history) }
    it { is_expected.to have_many(:authorizations) }
  end

  it 'factory can produce a valid model' do
    model = build(:data_management_plan, provenance: create(:provenance))
    expect(model.valid?).to eql(true), model.errors.full_messages
  end

  describe 'cascading deletes' do
    before :each do
      @provenance = create(:provenance)
      @project = create(:project)
      @model = create(:data_management_plan, project: @project, provenance: @provenance)
    end
    it 'does not delete the project' do
      @model.destroy
      expect(Project.last).to eql(@project)
    end
    it 'does not delete associated contributors' do
      contributor = create(:contributor, provenance: @provenance)
      @model.contributors_data_management_plans << build(:contributors_data_management_plan,
                                                         contributor: contributor,
                                                         role: 'http://credit.niso.org/contributor-roles/investigation',
                                                         provenance: @provenance)
      @model.save
      @model.destroy
      expect(Contributor.where(id: contributor.id).any?).to eql(true)
    end
    it 'deletes associated person_data_management_plans' do
      cdmp = build(:contributors_data_management_plan, contributor: create(:contributor),
                                                       role: 'http://credit.niso.org/contributor-roles/investigation',
                                                       provenance: @provenance)
      @model.contributors_data_management_plans << cdmp
      @model.save
      @model.destroy
      expect(ContributorsDataManagementPlan.where(id: cdmp.id).empty?).to eql(true)
    end
    it 'deletes associated costs' do
      cost = create(:cost)
      @model.costs << cost
      @model.save
      @model.destroy
      expect(Cost.where(id: cost.id).empty?).to eql(true)
    end
    it 'deletes associated datasets' do
      dataset = create(:dataset)
      @model.datasets << dataset
      @model.destroy
      expect(Dataset.where(id: dataset.id).empty?).to eql(true)
    end
    it 'deletes associated identifiers' do
      model = create(:metadatum, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  context 'instance methods' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete)
    end

    describe 'primary_contact' do
      it 'returns the correct contributor' do
        expect(@dmp.primary_contact.is_a?(Contributor)).to eql(true)
        expect(@dmp.primary_contact).to eql(ContributorsDataManagementPlan
          .where(role: 'primary_contact', data_management_plan_id: @dmp.id).first&.contributor)
      end
    end

    describe 'primary_contact=' do
      xit 'returns the primary_contact and only the primary_contact' do
        expect(@dmp.primary_contact.is_a?(Contributor)).to eql(true)
        expect(@dmp.primary_contact).to eql(ContributorsDataManagementPlan
          .where(role: 'primary_contact', data_management_plan_id: @dmp.id).first&.contributor)
      end
    end
  end
end
