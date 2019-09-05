require 'rails_helper'

RSpec.describe Api::V1::DataManagementPlansController, type: :request do

  before(:each) do
    auth = mock_access_token
    @dmps = [
      create(:data_management_plan, doorkeeper_application: @doorkeeper_application),
      create(:data_management_plan, doorkeeper_application: @doorkeeper_application)
    ]
    @other_dmp = create(:data_management_plan)
    @headers = default_authenticated_headers(authorization: auth)
  end

  describe :index do
    before(:each) do
      get api_v1_data_management_plans_path, headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json
    end

    it 'returns the data management plans owned by the client' do
      expect(@json['data_management_plans'].length).to eql(2)
    end

    it 'does not return data management plans owned by another client' do
      expect(@json['data_management_plans'].collect { |d| d[:id] }.include?(@other_dmp.id)).to eql(false)
    end
  end

  describe :show do
    it 'returns the requested data management plan' do
      get api_v1_data_management_plan_path(@dmps.first), headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json
      expect(@json).to eql(@dmps.first.to_json(%i[full_json]))
    end

    it 'returns a not_found if the data management plan does not exist' do
      get api_v1_data_management_plan_path(9999), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json).to eql(nil)
    end

    it 'returns a not_found if the data management plan is not owned by the client/application' do
      get api_v1_data_management_plan_path(@other_dmp), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json).to eql(nil)
    end
  end

end