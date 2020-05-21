# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClient, type: :model do
  context 'validations' do
    subject { create(:api_client) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:contact_email) }

    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to allow_values('one@example.com', 'foo-bar@ed.ac.uk').for(:contact_email) }
    it { is_expected.not_to allow_values('example.com', 'foo bar@ed.ac.uk').for(:contact_email) }
  end

  context 'associations' do
    it { is_expected.to have_many(:authorizations) }
    it { is_expected.to have_many(:permissions) }
    it { is_expected.to have_many(:history) }
  end

  context 'instance methods' do
    before(:each) do
      @model = build(:api_client)
    end

    it '#to_s returns the :name' do
      expect(@model.to_s).to eql(@model.name)
    end

    describe '#authenticate(secret:)' do
      it 'returns false if the :secret does not match' do
        expect(@model.authenticate(secret: SecureRandom.uuid)).to eql(false)
      end
      it 'returns true if the :secret matches' do
        expect(@model.authenticate(secret: @model.client_secret)).to eql(true)
      end
    end

    describe '#generate_credentials' do
      it 'replaces the :client_id' do
        prior = @model.client_id
        @model.generate_credentials
        expect(@model.client_id).not_to eql(prior)
      end
      it 'replaces the :client_secret' do
        prior = @model.client_secret
        @model.generate_credentials
        expect(@model.client_secret).not_to eql(prior)
      end
      it 'gets called when validating if :client_id is nil' do
        allow(@model).to receive(:generate_credentials).and_return(true)
        @model.client_id = nil
        @model.valid?
        expect(@model).to have_received(:generate_credentials)
      end
      it 'gets called when validating if :client_secret is nil' do
        allow(@model).to receive(:generate_credentials).and_return(true)
        @model.client_secret = nil
        @model.valid?
        expect(@model).to have_received(:generate_credentials)
      end
    end

    describe '#name_to_downcase' do
      it 'forces the :name to lower case' do
        @model.name = 'FoO'
        @model.send(:name_to_downcase)
        expect(@model.name).to eql('foo')
      end
      it 'gets called when validating' do
        allow(@model).to receive(:name_to_downcase).and_return(true)
        @model.save
        expect(@model).to have_received(:name_to_downcase)
      end
    end
  end
end
