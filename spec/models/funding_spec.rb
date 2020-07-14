# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Funding, type: :model do
  context 'validations' do
    it { is_expected.to define_enum_for(:status).with_values(Funding.statuses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:affiliation) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:authorizations) }
  end

  it 'factory can produce a valid model' do
    model = create(:funding, affiliation: build(:affiliation, provenance: build(:provenance)))
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the project' do
      project = create(:project)
      model = create(:funding, :complete, project: project)
      model.destroy
      expect(Project.last).to eql(project)
    end
    it 'does not delete the affiliation' do
      affiliation = create(:affiliation)
      model = create(:funding, :complete, affiliation: affiliation)
      model.destroy
      expect(Affiliation.last).to eql(affiliation)
    end
    it 'deletes associated identifiers' do
      model = create(:funding, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
    it 'deletes associated authorizations' do
      model = create(:funding, affiliation: create(:affiliation))
      create(:api_client_authorization, authorizable: model, api_client: create(:api_client))
      model.reload
      authorization = model.authorizations.first
      model.destroy
      expect(ApiClientAuthorization.where(id: authorization.id).empty?).to eql(true)
    end
  end

  describe '#funded?' do
    it 'returns false if the :status is not "granted"' do
      funding = create(:funding, :complete, status: 'applied')
      expect(funding.funded?).to eql(false)
    end
    it 'returns false if there is no :identifier of :category "url"' do
      funding = create(:funding, status: 'granted', affiliation: create(:affiliation))
      expect(funding.funded?).to eql(false)
    end
    it 'returns true' do
      funding = create(:funding, :complete, status: 'granted')
      expect(funding.funded?).to eql(true)
    end
  end

  describe '#ensure_status' do
    it 'sets the default :status' do
      funding = build(:funding, status: nil)
      funding.send(:ensure_status)
      expect(funding.status).to eql('planned')
    end
    it 'does not overwrite the existing :status' do
      funding = build(:funding, status: 'applied')
      funding.send(:ensure_status)
      expect(funding.status).to eql('applied')
    end
  end
end
