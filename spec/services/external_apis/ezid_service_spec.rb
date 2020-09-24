# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::EzidService, type: :model do
  include DataciteMocks

  describe '#auth' do
    before(:each) do
      @hash = described_class.send(:auth)
    end

    xit 'returns the correct username' do
      expect(@hash.include?(:username)).to eql(true)
      expect(@hash[:username]).to eql(Rails.configuration.x.datacite.client_id)
    end

    xit 'returns the correct password' do
      expect(@hash.include?(:password)).to eql(true)
      expect(@hash[:password]).to eql(Rails.configuration.x.datacite.client_secret)
    end
  end

  describe '#mint_doi' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete, project: create(:project))
      stub_minting_error!
    end

    xit 'returns the new DOI' do
      stub_minting_success!
      doi = described_class.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi).to eql('10.99999/abc123-566')
    end

    xit 'returns nil if Datacite returned an error' do
      doi = described_class.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi).to eql(nil)
    end
  end
end
