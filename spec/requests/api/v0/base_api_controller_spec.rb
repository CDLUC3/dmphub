# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::BaseApiController, type: :request do
  before(:each) do
    @client = create(:api_client)
    # @token = mock_access_token(client: @client)
    @controller = MockController.new
  end

  context 'actions' do
    describe 'heartbeat (GET api/v0/heartbeat)' do
      it 'returns a 200 status' do
        get api_v0_heartbeat_path
        expect(response.code).to eql('200')
      end
    end
  end

  context 'protected methods' do
    describe 'render_error(errors:, status:)' do
      before(:each) do
        # Add our test route for rendering errors
        Rails.application.routes.draw do
          get '/api/v0/force_error', controller: 'mock', action: 'force_error'
        end
      end
      it 'renders an error' do
        allow_any_instance_of(MockController).to receive(:authorize_request).and_return(true)
        allow_any_instance_of(MockController).to receive(:check_agent).and_return(true)
        get api_v0_force_error_path
        expect(assigns(:payload)).to eql({ errors: @controller.errors })
        expect(response).to render_template('api/v0/error')
      end
      after(:each) do
        # Rebuild the routes
        Rails.application.reload_routes!
      end
    end
  end

  context 'private methods' do
    # See the awards_controller_spec.rb for tests of most of these method's
    # callbacks since this controller's only endpoint, :heartbeat, skips them
    describe '#authorize_request' do
      before(:each) do
        @client = create(:api_client)
        struct = OpenStruct.new(headers: {})
        allow(@controller).to receive(:request).and_return(struct)
      end

      it 'calls log_access if the authorization succeeds' do
        auth_svc = OpenStruct.new(call: @client)
        allow(Api::V0::Auth::Jwt::AuthorizationService).to receive(:new).and_return(auth_svc)
        allow(@controller).to receive(:log_access).and_return(true)
        @controller.send(:authorize_request)
        expect(@controller).to have_received(:log_access)
        @controller.send(:authorize_request)
      end

      it 'sets the client if the authorization succeeds' do
        auth_svc = OpenStruct.new(call: @client)
        allow(Api::V0::Auth::Jwt::AuthorizationService).to receive(:new).and_return(auth_svc)
        @controller.send(:authorize_request)
        expect(@controller.client).to eql(@client)
      end

      it 'renders an UNAUTHORIZED error if the client is not authorized' do
        auth_svc = OpenStruct.new(call: nil)
        allow(Api::V0::Auth::Jwt::AuthorizationService).to receive(:new).and_return(auth_svc)
        allow(@controller).to receive(:render_error).and_return(true)
        @controller.send(:authorize_request)
        expect(@controller).to have_received(:render_error)
      end
    end

    describe '#check_agent' do
      before(:each) do
        @mock_request = OpenStruct.new(headers: {})
        allow_any_instance_of(MockController).to receive(:authorize_request).and_return(true)
        allow_any_instance_of(MockController).to receive(:client).and_return(@client)
      end
      it 'returns false if HTTP_USER_AGENT is not present' do
        expect(@controller).to receive(:request).and_return(@mock_request)
        expect(@controller.send(:check_agent)).to eql(false)
      end
      it 'returns false if HTTP_USER_AGENT does not match the current client' do
        expected = "#{@client.name} (#{SecureRandom.uuid})"
        @mock_request.headers['HTTP_USER_AGENT'] = expected
        expect(@controller).to receive(:request).and_return(@mock_request)
        expect(@controller.send(:check_agent)).to eql(false)
      end
      it 'returns true' do
        expected = "#{@client.name} (#{@client.client_id})"
        @mock_request.headers['HTTP_USER_AGENT'] = expected
        expect(@controller).to receive(:request).times(2).and_return(@mock_request)
        expect(@controller.send(:check_agent)).to eql(true)
      end
    end

    describe '#parse_request' do
      before(:each) do
        allow_any_instance_of(MockController).to receive(:authorize_request).and_return(true)
        allow_any_instance_of(MockController).to receive(:client).and_return(@client)
      end

      it 'returns false if request is not present' do
        expect(@controller).to receive(:request).and_return(nil)
        expect(@controller.send(:parse_request)).to eql(false)
      end
      it 'returns false if request has no body' do
        @mock_request = OpenStruct.new(headers: [])
        expect(@controller).to receive(:request).and_return(@mock_request, @mock_request)
        expect(@controller.send(:parse_request)).to eql(false)
      end
      it 'returns false if there is a JSON parse error' do
        @mock_request = OpenStruct.new(body: OpenStruct.new(read: '{"invalid":"json"'))
        expect(@controller).to receive(:request).and_return(@mock_request, @mock_request, @mock_request, @mock_request)
        expect(Rails.logger).to receive(:error).and_return(true, true)
        expect(@controller).to receive(:render_error).and_return(true)
        expect(@controller.send(:parse_request)).to eql(false)
      end
      it 'returns the JSON' do
        @mock_request = OpenStruct.new(body: OpenStruct.new(read: '{"valid":"json"}'))
        expect(@controller).to receive(:request).and_return(@mock_request, @mock_request, @mock_request)
        expect(@controller.send(:parse_request)).to eql(JSON.parse(@mock_request.body.read))
      end
    end

    describe 'methods that require full request-response interaction' do
      before(:each) do
        # Add our test route for rendering errors
        Rails.application.routes.draw do
          get '/api/v0/success', controller: 'mock', action: 'success'
        end
        allow_any_instance_of(MockController).to receive(:authorize_request).and_return(true)
        allow_any_instance_of(MockController).to receive(:check_agent).and_return(true)
      end
      it '#set_default_response_format - forces JSON' do
        get api_v0_success_path
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
      it '#base_response_content - assigns the variables' do
        allow_any_instance_of(MockController).to receive(:caller_name).and_return('foo')
        get api_v0_success_path
        json = body_to_json
        expect(json[:application]).to eql(ApplicationService.application_name)
        expect(json[:caller]).to eql('foo')
      end
      describe '#pagination_params' do
        it 'assigns the default variables' do
          get api_v0_success_path
          expect(assigns(:page)).to eql(1)
          expect(assigns(:per_page)).to eql(20)
        end
        it 'sets the variables to the specified values' do
          get api_v0_success_path, params: { page: 3, per_page: 50 }
          expect(assigns(:page)).to eql(3)
          expect(assigns(:per_page)).to eql(50)
        end
        it 'does not allow per_page > 100' do
          get api_v0_success_path, params: { per_page: 101 }
          expect(assigns(:per_page)).to eql(100)
        end
      end
      after(:each) do
        # Rebuild the routes
        Rails.application.reload_routes!
      end
    end

    describe '#log_access' do
      it 'returns false if the client is not set' do
        allow(@controller).to receive(:client).and_return(nil)
        expect(@controller.send(:log_access)).to eql(false)
      end
      it 'returns true if the client is set' do
        @client = create(:api_client)
        allow(@controller).to receive(:client).and_return(@client)
        expect(@controller.send(:log_access)).to eql(true)
      end
      it 'updates the api_client.last_access if client is an ApiClient' do
        @client = create(:api_client)
        time = @client.last_access
        allow(@controller).to receive(:client).and_return(@client)
        @controller.send(:log_access)
        expect(time).not_to eql(@client.reload.last_access)
      end
    end

    describe '#caller_name' do
      it 'returns the caller\'s IP if the client is nil' do
        ip = Faker::Internet.ip_v4_address
        allow(@controller).to receive(:client).and_return(nil)
        allow(@controller).to receive(:request).and_return(OpenStruct.new(remote_ip: ip))
        expect(@controller.send(:caller_name)).to eql(ip)
      end
      it 'returns the client name if the client is a ApiClient' do
        @client = create(:api_client)
        allow(@controller).to receive(:client).and_return(@client)
        expect(@controller.send(:caller_name)).to eql(@client.name)
      end
    end

    describe '#paginate_response(results:)' do
      before(:each) do
        # Add our test route for rendering errors
        Rails.application.routes.draw do
          get '/api/v0/paginator', controller: 'mock', action: 'paginator'
        end
        allow_any_instance_of(MockController).to receive(:authorize_request).and_return(true)
        allow_any_instance_of(MockController).to receive(:check_agent).and_return(true)

        Affiliation.destroy_all
        4.times { create(:affiliation) }
        @orgs = Affiliation.all
      end

      it 'sets the results to the correct page' do
        get api_v0_paginator_path, params: { page: 2, per_page: 2 }
        expect(assigns(:payload)[:items].first).to eql(Affiliation.all.third)
      end
      it 'sets the results to the correct per_page' do
        get api_v0_paginator_path, params: { page: 2, per_page: 2 }
        expect(assigns(:payload)[:items].length).to eql(2)
      end
      it 'sets the total_items variable' do
        get api_v0_paginator_path, params: { page: 2, per_page: 2 }
        expect(assigns(:total_items)).to eql(4)
      end

      after(:each) do
        # Rebuild the routes
        Rails.application.reload_routes!
      end
    end
  end
end

# Mock controller to test BaseApiController methods
class MockController < Api::V0::BaseApiController
  attr_reader :errors

  def force_error
    @errors = [Faker::Lorem.sentence, Faker::Lorem.sentence]
    render_error(errors: @errors, status: :bad_request)
  end

  def success
    render 'api/v0/heartbeat', status: :ok
  end

  def paginator
    @payload = { items: paginate_response(results: Affiliation.all) }
    @dmps = []
    render 'api/v0/data_management_plans/index', status: :ok
  end
end
