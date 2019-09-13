require 'rails_helper'

RSpec.describe Api::V1::DataManagementPlansController, type: :request do

  before(:each) do
    auth = mock_access_token
    @dmps = [
      create(:data_management_plan, :complete, doorkeeper_application: @doorkeeper_application),
      create(:data_management_plan, :complete, doorkeeper_application: @doorkeeper_application)
    ]
    @other_dmp = create(:data_management_plan, :complete)
    @headers = default_authenticated_headers(authorization: auth)
  end

  describe :index do
    before(:each) do
      get api_v1_data_management_plans_path, headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json['content']
    end

    it 'returns the data management plans owned by the client' do
      expect(@json['dmps'].length).to eql(2)
    end

    it 'does not return data management plans owned by another client' do
      dmps = @json['dmps'].select do |dmp|
        dmp['links'].first['href'].ends_with?(api_v1_data_management_plan_path(@other_dmp.id.to_s))
      end
      expect(dmps.empty?).to eql(true)
    end
  end

  describe :show do
    it 'returns the requested data management plan' do
      # TODO: This one is failing for some reason when running the full test
      #       suite via `rspec` it passes without issue when running either the
      #       individual file or all of the request tests
      get api_v1_data_management_plan_path(@dmps.first), headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json['content']
      received = @json['dmp']['links'].first['href']
      expect(received.ends_with?(api_v1_data_management_plan_path(@dmps.first))).to eql(true)
    end

    it 'returns a not_found if the data management plan does not exist' do
      get api_v1_data_management_plan_path(9999), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json).to eql({})
    end

    it 'returns a not_found if the data management plan is not owned by the client/application' do
      get api_v1_data_management_plan_path(@other_dmp), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json).to eql({})
    end
  end

  describe :create do
    before(:each) do
      @file_path = Rails.root.join('spec', 'support', 'mocks')
    end

    context 'minimal JSON' do
      before(:each) do
        @payload = File.read("#{@file_path}/rda_madmp_common_standard_minimal.json")
      end

      it 'returns a created/201 if the data management plan was created' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        expect(response.status).to eql(201)
        expect(validate_base_response(json: body_to_json)).to eql(true)
      end

      it 'returns the DOI as part of the response' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        doi = body_to_json['content']['dmp']['dmp_ids'].first
        expect(doi['category']).to eql('doi')
        expect(doi['value'].present?).to eql(true)
        expect(doi['provenance'].present?).to eql(true)
      end

      # TODO: We need to add matching logic to determine if the incoming
      #       DMP already exists
      xit 'returns a bad_request if the data management plan already exists' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        expect(response.status).to eql(400)
        expect(body_to_json).to eql(nil)
      end
    end

    context 'complete JSON' do
      before(:each) do
        @payload = File.read("#{@file_path}/complete_common_standard.json")
      end

      it 'returns a created/201 if the data management plan was created' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        expect(response.status).to eql(201)
        expect(validate_base_response(json: body_to_json)).to eql(true)
      end

      it 'returns the DOI as part of the response' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        doi = body_to_json['content']['dmp']['dmp_ids'].first
        expect(doi['category']).to eql('doi')
        expect(doi['value'].present?).to eql(true)
        expect(doi['provenance'].present?).to eql(true)
      end

      # TODO: We need to add matching logic to determine if the incoming
      #       DMP already exists
      xit 'returns a bad_request if the data management plan already exists' do
        post api_v1_data_management_plans_path, params: @payload, headers: @headers
        expect(response.status).to eql(400)
        expect(body_to_json).to eql(nil)
      end
    end
  end

end