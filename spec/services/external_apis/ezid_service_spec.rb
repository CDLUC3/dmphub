# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::EzidService, type: :model do
  include Mocks::Ror
  include Mocks::Ezid

  describe '#mint_doi' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete, project: create(:project))
    end

    it 'returns the new DOI' do
      mock_ezid_success
      doi = described_class.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi.present?).to eql(true)
    end

    it 'returns an empty array if EZID returned an error' do
      mock_ezid_failure
      doi = described_class.mint_doi(data_management_plan: @dmp, provenance: Faker::Lorem.word)
      expect(doi).to eql([])
    end
  end
end
