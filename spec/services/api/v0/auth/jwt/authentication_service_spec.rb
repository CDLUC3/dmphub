# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Auth::Jwt::AuthenticationService do
  before(:each) do
    @jwt = SecureRandom.uuid
    allow(Api::V0::Auth::Jwt::JsonWebToken).to receive(:encode).and_return(@jwt)
  end

  context 'instance methods' do
    describe '#initialize(json:)' do
      it 'sets errors to empty hash' do
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: Faker::Lorem.word, client_secret: Faker::Lorem.word
          }
        )
        expect(svc.errors).to eql({})
      end
      it 'defaults :grant_type to client_credentials' do
        id = Faker::Lorem.word
        svc = described_class.new(
          json: {
            client_id: id,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(id)
      end
      it 'does not accept invalid :grant_type' do
        svc = described_class.new(
          json: {
            grant_type: Faker::Lorem.word,
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(nil)
      end
      it 'accepts client_credentials :grant_type' do
        id = Faker::Lorem.word
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: id,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(id)
      end
    end

    describe '#call' do
      it 'returns null if the client_id is empty' do
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: nil,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.call).to eql(nil)
      end

      it 'returns null if the client_secret is empty' do
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: Faker::Lorem.word,
            client_secret: nil
          }
        )
        expect(svc.call).to eql(nil)
      end

      it 'defers to the private #client method' do
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        allow(svc).to receive(:client).and_return(true)
        svc.call
        expect(svc).to have_received(:client)
      end

      it 'returns nil if the #client method returned nil' do
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        allow(svc).to receive(:client).and_return(nil)
        expect(svc.call).to eql(nil)
      end

      it 'returns nil if the Client is not an ApiClient' do
        org = build(:affiliation)
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: org.name,
            client_secret: SecureRandom.uuid
          }
        )
        allow(svc).to receive(:client).and_return(org)
        expect(svc.call).to eql(nil)
      end

      it 'returns a JSON Web Token and Expiration Time for ApiClient' do
        client = create(:api_client)
        svc = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: client.client_id,
            client_secret: client.client_secret
          }
        )
        allow(svc).to receive(:client).and_return(client)
        expect(svc.call).to eql(@jwt)
      end
    end
  end

  context 'private methods' do
    describe '#client' do
      before(:each) do
        @service = described_class.new
      end

      it 'is a singleton method' do
        client = create(:api_client)
        allow(@service).to receive(:authenticate_client).and_return(client)
        @service.send(:client)
        expect(@service).to have_received(:authenticate_client)
      end
      it 'returns nil if no ApiClient was authenticated' do
        allow(@service).to receive(:authenticate_client).and_return(nil)
        rslt = @service.send(:client)
        expect(@service.send(:client)).to eql(rslt)
      end
      it 'returns the api_client if a ApiClient was authenticated' do
        client = create(:api_client)
        allow(@service).to receive(:authenticate_client).and_return(client)
        expect(@service.send(:client)).to eql(client)
      end
      it 'adds "invalid credentials" to errors if nothing authenticated' do
        allow(@service).to receive(:authenticate_client).and_return(nil)
        @service.send(:client)
        msg = 'Invalid credentials'
        expect(@service.errors[:client_authentication]).to eql(msg)
      end
    end

    describe '#authenticate_client' do
      before(:each) do
        @client = create(:api_client)
        @service = described_class.new(
          json: {
            grant_type: 'client_credentials',
            client_id: @client.client_id,
            client_secret: @client.client_secret
          }
        )
      end

      it 'returns nil if no ApiClient is matched' do
        @client.destroy
        expect(@service.send(:authenticate_client)).to eql(nil)
      end
      it 'returns nil if the matching ApiClient did not auth' do
        @client.update(client_secret: SecureRandom.uuid)
        expect(@service.send(:authenticate_client)).to eql(nil)
      end
      it 'returns the ApiClient' do
        expect(@service.send(:authenticate_client)).to eql(@client)
      end
    end

    describe '#parse_client' do
      before(:each) do
        @service = described_class.new
        @client_id = SecureRandom.uuid
        @client_secret = SecureRandom.uuid
      end

      it 'sets the client_id to nil if its is not in JSON' do
        @service.send(
          :parse_client,
          json: {
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_id)).to eql(nil)
      end
      it 'sets the client_secret to nil if its is not in JSON' do
        @service.send(:parse_client, json: { client_id: @client_id })
        expect(@service.send(:client_secret)).to eql(nil)
      end
      it 'sets the client_id' do
        @service.send(
          :parse_client,
          json: {
            client_id: @client_id,
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_id)).to eql(@client_id)
      end
      it 'sets the client_secret' do
        @service.send(
          :parse_client,
          json: {
            client_id: @client_id,
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_secret)).to eql(@client_secret)
      end
    end
  end
end
