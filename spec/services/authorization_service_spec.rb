# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizationService, type: :model do

  before :each do
    @dmp = create(:project, :complete).data_management_plans.first
    @app = create(:doorkeeper_application)
  end

  describe 'authorize!' do
    it 'returns nil if the dmp is nil' do
      expect(AuthorizationService.authorize!(dmp: nil, entity: @app)).to eql(nil)
    end
    it 'returns nil if the dmp is not an instance of a DataManagementPlan' do
      expect(AuthorizationService.authorize!(dmp: build(:award), entity: @app)).to eql(nil)
    end
    it 'returns nil if the dmp is not a new record' do
      expect(AuthorizationService.authorize!(dmp: build(:data_management_plan), entity: @app)).to eql(nil)
    end
    it 'returns nil if the entity is nil' do
      expect(AuthorizationService.authorize!(dmp: @dmp, entity: nil)).to eql(nil)
    end
    it 'returns nil if the entity is not an instance of a Doorkeeper::Application' do
      expect(AuthorizationService.authorize!(dmp: @dmp, entity: build(:person))).to eql(nil)
    end
    it 'creates an authorization' do
      auth = AuthorizationService.authorize!(dmp: @dmp, entity: @app)
      expect(auth.is_a?(OauthAuthorization)).to eql(true)
      expect(auth.oauth_application).to eql(@app)
      expect(auth.data_management_plan).to eql(@dmp)
    end
  end

  describe 'authorized?' do
    it 'is expected to be false if the permission is nil' do
      expect(AuthorizationService.authorized?(dmp: @dmp, entity: @app, permission: nil)).to eql(false)
    end
    it 'is expected to be false if the dmp is nil' do
      expect(AuthorizationService.authorized?(dmp: nil, entity: @app, permission: 1)).to eql(false)
    end
    it 'is expected to be false if the dmp is not an instance of a DataManagementPlan' do
      expect(AuthorizationService.authorized?(dmp: build(:project), entity: @app, permission: 1)).to eql(false)
    end
    it 'is expected to be false if the entity is nil' do
      expect(AuthorizationService.authorized?(dmp: @dmp, entity: nil, permission: 1)).to eql(false)
    end
    it 'is expected to be false if the entity is not an instance of a Doorkeeper::Application or a User' do
      expect(AuthorizationService.authorized?(dmp: @dmp, entity: build(:award), permission: 1)).to eql(false)
    end
    it 'is expected to be false if the Application does not have permission' do
    end
    it 'is expected to be false if the User does not have permission' do
    end
    it 'is expected to be true if the Application has permission' do
    end
    it 'is expected to be true if the User has permission' do
    end
  end

end
