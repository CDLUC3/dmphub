# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClientAuthorization, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:api_client) }
    it { is_expected.to belong_to(:authorizable) }
  end

  context 'scopes' do
    before(:each) do
      @client = create(:api_client)
      @dmp = create(:data_management_plan, :complete)
      @other_dmp = create(:data_management_plan, :complete)
      @dmp.authorize!(api_client: @client)
      @type = 'DataManagementPlan'
    end

    describe '#by_api_client_and_type(api_client_id:, authorizable_type:)' do
      it 'returns an empty array if :api_client_id is invalid' do
        results = described_class.by_api_client_and_type(api_client_id: nil, authorizable_type: @type)
        expect(results.empty?).to eql(true)
      end
      it 'returns an empty array if :authorizable_type has no matches' do
        results = described_class.by_api_client_and_type(api_client_id: @client.id, authorizable_type: 'Project')
        expect(results.empty?).to eql(true)
      end
      it 'returns the records' do
        results = described_class.by_api_client_and_type(api_client_id: @client.id, authorizable_type: @type)
                                 .pluck(:authorizable_id)
        expect(results.include?(@dmp.id)).to eql(true)
        expect(results.include?(@other_dmp.id)).to eql(false)
      end
    end
  end
end
