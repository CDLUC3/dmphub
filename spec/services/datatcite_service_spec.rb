# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataciteService, type: :model do
  include DataciteMocks

  describe 'options' do
    before(:each) do
      @hash = DataciteService.send(:options)
    end

    it 'returns the correct username' do
      expect(@hash.include?(:username)).to eql(true)
      expect(@hash[:username]).to eql(DATACITE_CLIENT_ID)
    end

    it 'returns the correct password' do
      expect(@hash.include?(:password)).to eql(true)
      expect(@hash[:password]).to eql(DATACITE_CLIENT_SECRET)
    end
  end

  describe 'headers' do
    before(:each) do
      @hash = DataciteService.send(:headers)
    end

    it 'returns the correct User-Agent header' do
      expect(@hash.include?(:'User-Agent')).to eql(true)
      expect(@hash[:'User-Agent']).to eql(Rails.application.class.name.split('::').first)
    end

    it 'returns the correct Content-Type header' do
      expect(@hash.include?(:'Content-Type')).to eql(true)
      expect(@hash[:'Content-Type']).to eql('application/vnd.api+json')
    end

    it 'returns the correct Accept header' do
      expect(@hash.include?(:Accept)).to eql(true)
      expect(@hash[:Accept]).to eql('application/json')
    end
  end

  describe 'mint_doi' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete, project: create(:project))
      stub_minting_error!
    end

    it 'returns the new DOI' do
      stub_minting_success!
      doi = DataciteService.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi).to eql('10.99999/abc123-566')
    end

    it 'returns nil if Datacite returned an error' do
      doi = DataciteService.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi).to eql(nil)
    end
  end
end
