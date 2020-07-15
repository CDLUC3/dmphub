# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::DataManagementPlansController, type: :request do
  include DataciteMocks

  before(:each) do
    @client = create(:api_client)
    create(:api_client_permission, api_client: @client, permission: 'data_management_plan_creation')
    auth = mock_access_token(client: @client)
    @dmps = [
      create(:data_management_plan, :complete),
      create(:data_management_plan, :complete)
    ]
    @dmps.each { |dmp| dmp.authorize!(api_client: @client) }
    @other_dmp = create(:data_management_plan, :complete)
    @headers = default_authenticated_headers(client: @client, token: auth)
  end

  describe :index do
    before(:each) do
      get api_v0_data_management_plans_path, headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json
    end

    it 'returns the data management plans owned by the client' do
      expect(@json['items'].length).to eql(2)
    end

    it 'does not return data management plans owned by another client' do
      dmps = @json['items'].map { |item| item['dmp'] }.select do |dmp|
        dmp['dmp_id']['type'] == 'DOI' && dmp['dmp_id']['identifier'] == @other_dmp.dois.first
      end
      expect(dmps.empty?).to eql(true)
    end
  end

  describe :show do
    it 'returns the requested data management plan' do
      doi = @dmps.first.identifiers.first&.value
      get "/api/v0/data_management_plans/#{doi}", headers: @headers
      expect(response.status).to eql(200)
      @json = body_to_json
      received = @json['items'].first
      expect(received.present?).to eql(true)
      expect(received['dmp']['dmp_id']['identifier']).to eql(doi)
    end

    it 'returns a not_found if the data management plan does not exist' do
      get api_v0_data_management_plan_path(9999), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json['total_items']).to eql(0)
    end

    it 'returns a not_found if the data management plan is not owned by the client/application' do
      get api_v0_data_management_plan_path(@other_dmp), headers: @headers
      expect(response.status).to eql(404)
      expect(body_to_json['total_items']).to eql(0)
    end
  end

  describe :create do
    before(:each) do
      @file_path = Rails.root.join('spec', 'support', 'mocks')
    end

    it 'returns a 400 bad_request if the json input does not have a `dmp`' do
      post api_v0_data_management_plans_path, params: { 'dmp': {} }, headers: @headers
      expect(response.status).to eql(400)
      expect(body_to_json['errors'].downcase).to eql('invalid json format')
    end

    context 'minimal JSON' do
      before(:each) do
        stub_minting_success!
        json = File.read("#{@file_path}/rda_madmp_common_standard_minimal.json")
        @payload = JSON.parse(json)
      end

      it 'returns a 400 bad_request if the json input does not represent a valid Data Management Plan' do
        @payload['dmp'].delete('title')
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        expect(response.status).to eql(400)
        expect(body_to_json['errors'].downcase.start_with?('invalid json format')).to eql(true)
      end

      it 'returns a created/201 if the data management plan was created' do
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        expect(response.status).to eql(201)
        expect(validate_base_response(json: body_to_json)).to eql(true)
      end

      it 'returns the DOI as part of the response' do
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        doi = body_to_json['items'].first['dmp']['dmp_id'].first
        expect(doi['type']).to eql('doi')
        expect(doi['identifier'].present?).to eql(true)
      end

      # TODO: We need to add matching logic to determine if the incoming
      #       DMP already exists
      it 'returns a bad_request if the data management plan already exists' do
        dmp = DataManagementPlan.from_json(json: @payload['dmp'], provenance: Faker::Lorem.word)
        dmp.save
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        expect(response.status).to eql(400)
        expect(body_to_json['errors'].first['dmp']).to eql('already exists')
      end
    end

    context 'complete JSON' do
      before(:each) do
        stub_minting_success!
        json = File.read("#{@file_path}/complete_common_standard.json")
        @payload = JSON.parse(json)
      end

      it 'returns a created/201 if the data management plan was created' do
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        expect(response.status).to eql(201)
        expect(validate_base_response(json: body_to_json)).to eql(true)
      end

      it 'returns the DOI as part of the response' do
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        doi = body_to_json['content']['dmp']['dmp_ids'].first
        expect(doi['category']).to eql('doi')
        expect(doi['value'].present?).to eql(true)
        expect(doi['provenance'].present?).to eql(true)
      end

      # TODO: We need to add matching logic to determine if the incoming
      #       DMP already exists
      it 'returns a bad_request if the data management plan already exists' do
        dmp = DataManagementPlan.from_json(json: @payload['dmp'], provenance: Faker::Lorem.word)
        dmp.save
        post api_v0_data_management_plans_path, params: @payload.to_json, headers: @headers
        expect(response.status).to eql(400)
        expect(body_to_json['errors'].first['dmp']).to eql('already exists')
      end
    end
  end
end
