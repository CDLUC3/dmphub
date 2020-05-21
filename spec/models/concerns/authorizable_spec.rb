# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authorizable do
  context 'associations' do
    it 'has a have_many relationship with :authorizations' do
      expect(DataManagementPlan.new.respond_to?(:authorizations)).to eql(true)
    end
  end

  context 'instance methods' do
    before(:each) do
      @client = create(:api_client)
      @model = create(:data_management_plan)
      @auth = create(:api_client_authorization, authorizable: @model, api_client: @client)
    end

    describe '#authorized?(api_client:)' do
      it 'returns false if :api_client is not an ApiClient' do
        expect(@model.authorized?(api_client: Project.new)).to eql(false)
      end
      it 'returns false if :api_client is not present' do
        expect(@model.authorized?(api_client: nil)).to eql(false)
      end
      it 'returns false if the ApiClient is NOT authorized on the Authorizable' do
        @auth.destroy
        expect(@model.authorized?(api_client: @client)).to eql(false)
      end
      it 'returns true if the ApiClient is authorized on the Authorizable' do
        expect(@model.authorized?(api_client: @client)).to eql(true)
      end
    end

    describe '#authorize!(api_client:)' do
      it 'returns false if :api_client is not an ApiClient' do
        expect(@model.authorize!(api_client: Project.new)).to eql(false)
      end
      it 'returns false if :api_client is not present' do
        expect(@model.authorize!(api_client: nil)).to eql(false)
      end
      it 'creates the authorization' do
        client2 = create(:api_client)
        expect(@model.authorize!(api_client: client2)).to eql(true)
        expect(ApiClientAuthorization.last.api_client).to eql(client2)
      end
    end
  end
end
