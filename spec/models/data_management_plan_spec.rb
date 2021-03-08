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
      before(:each) do
        @dmp.contributors_data_management_plans.destroy_all
        @dmp.reload
        @contributor = create(:contributor)
        @cdmp = build(:contributors_data_management_plan, contributor: @contributor, role: 'primary_contact')
      end

      it 'does not change the primary contact if :value is not a Contributor' do
        @dmp.contributors_data_management_plans << @cdmp
        @dmp.primary_contact = build(:affiliation)
        expect(@dmp.primary_contact).to eql(@contributor)
      end

      it 'sets the :primary_contact when there was none prior' do
        @dmp.primary_contact = @contributor
        cdmps = @dmp.contributors_data_management_plans
        expect(@dmp.primary_contact).to eql(@contributor)
        expect(cdmps.last.role).to eql('primary_contact')
        expect(cdmps.last.contributor).to eql(@contributor)
      end

      context 'when there is an existing :primary_contact' do
        before(:each) do
          # Set the initial primary
          @dmp.contributors_data_management_plans << @cdmp
          @new_contact = build(:contributor)
        end

        it 'destroys the existing ContributorDatamanagementPlan but not the Contributor' do
          @dmp.primary_contact = @new_contact
          cdmps = @dmp.contributors_data_management_plans
          expect(cdmps.length).to eql(1)
          expect(@dmp.primary_contact).to eql(@new_contact)
        end
        it 'does not change anything if the specified contributor is already the :primary_contact' do
          @dmp.primary_contact = @contributor
          cdmps = @dmp.contributors_data_management_plans
          expect(@dmp.primary_contact).to eql(@contributor)
          expect(cdmps.last.role).to eql('primary_contact')
          expect(cdmps.last.contributor).to eql(@contributor)
        end
        it 'replaces the current :primary_contact' do
          @dmp.primary_contact = @new_contact
          cdmps = @dmp.contributors_data_management_plans
          expect(@dmp.primary_contact).to eql(@new_contact)
          expect(cdmps.last.role).to eql('primary_contact')
          expect(cdmps.last.contributor).to eql(@new_contact)
        end
      end
    end

    describe 'doi' do
      it 'returns nil if there are no identifiers at all' do
        @dmp.identifiers.clear
        expect(@dmp.doi).to eql(nil)
      end
      it 'returns nil if there are is a doi but its not an is_identified_by identifier' do
        @dmp.identifiers.clear
        @dmp.identifiers << build(:identifier, category: 'doi', descriptor: 'is_referenced_by')
        expect(@dmp.doi).to eql(nil)
      end

      %w[other ark doi].each do |category|
        it "returns #{category == 'other' ? 'nil' : 'an identifier'} when there is a :#{category}" do
          @dmp.identifiers.clear
          id = build(:identifier, category: category, descriptor: 'is_identified_by')
          @dmp.identifiers << id
          expect(@dmp.doi).to eql(category == 'other' ? nil : id)
        end
      end
    end

    describe 'mint_doi' do
      before(:each) do
        @dmp.identifiers.clear
      end

      it 'calls out to EzidService.mint_doi when not in dev mode and returns a DOI' do
        id = build(:identifier, category: 'doi', descriptor: 'is_identified_by')
        allow(ExternalApis::EzidService).to receive(:mint_doi).and_return([id])
        expect(@dmp.mint_doi(provenance: build(:provenance))).to eql(true)
        expect(ExternalApis::EzidService).to have_received(:mint_doi)
        expect(@dmp.doi.value).to eql(id.value)
      end
      it 'calls out to EzidService.mint_doi when not in dev mode and returns a ARK' do
        id = build(:identifier, category: 'ark', descriptor: 'is_identified_by')
        allow(ExternalApis::EzidService).to receive(:mint_doi).and_return([id])
        expect(@dmp.mint_doi(provenance: build(:provenance))).to eql(true)
        expect(@dmp.doi.value).to eql(id.value)
      end
      it 'fails if there are no DOIs or ARKs after EzidService.mint_doi' do
        id = build(:identifier, category: 'other')
        allow(ExternalApis::EzidService).to receive(:mint_doi).and_return([id])
        expect(@dmp.mint_doi(provenance: build(:provenance))).to eql(false)
      end
    end

    context 'private methods' do
      describe 'ensure_dataset callback' do
        it 'does not add a default dataset if the DMP has one already' do
          @dmp.datasets.clear
          dataset = build(:dataset)
          @dmp.datasets << dataset
          @dmp.send(:ensure_dataset)
          expect(@dmp.datasets.length).to eql(1)
          expect(@dmp.datasets.last.title).to eql(dataset.title)
        end
        it 'adds a default dataset' do
          @dmp.datasets.clear
          @dmp.send(:ensure_dataset)
          expect(@dmp.datasets.length).to eql(1)
          expect(@dmp.datasets.first.title).to eql(@dmp.title)
        end
      end

      describe 'check_version callback' do
        it 'returns true if :version did not change' do
          expect(@dmp.send(:check_version)).to eql(true)
        end
        it 'returns true if DMP has no :doi' do
          @dmp.identifiers.clear
          expect(@dmp.send(:check_version)).to eql(true)
        end
        it 'returns true after calling EzidService.update_doi' do
          @dmp.identifiers << build(:identifier, category: 'doi', descriptor: 'is_identified_by')
          @dmp.version = Time.now + 5.minutes
          allow(ExternalApis::EzidService).to receive(:update_doi).and_return(true)

          expect(@dmp.send(:check_version)).to eql(true)
          expect(ExternalApis::EzidService).to have_received(:update_doi)
        end
      end

      describe 'mock_doi' do
        it 'returns a fake DOI' do
          doi_regex = /https:\/\/doi.org\/[0-9]{2}\.[0-9]{4}\/[a-zA-Z0-9]{6}/
          expect(@dmp.send(:mock_doi) =~ doi_regex).to eql(0)
        end
      end
    end
  end

  context 'DEV mode testing' do
    before(:each) do
      @dmp = build(:data_management_plan)
    end
    describe 'mint_doi' do
      it 'gets a mock DOI when in dev mode' do
        Rails.env = 'development'
        allow(@dmp).to receive(:mock_doi).and_return('foo')
        expect(@dmp.mint_doi(provenance: build(:provenance))).to eql(true)
        expect(@dmp).to have_received(:mock_doi)
        expect(@dmp.doi.value).to eql('foo')
      end
    end
    describe 'check_version callback' do
      it 'returns true if in dev mode' do
        Rails.env = 'development'
        expect(@dmp.send(:check_version)).to eql(true)
      end
    end
  end
end
