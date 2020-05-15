# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OauthApplicationProfile, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:oauth_application) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:oauth_application) }
  end

  it 'factory can produce a valid model' do
    model = create(:oauth_application_profile, oauth_application: create(:doorkeeper_application))
    expect(model.valid?).to eql(true)
  end

  describe 'authorized_entities' do
    before(:each) do
      @profile = create(:oauth_application_profile, oauth_application: create(:doorkeeper_application))
    end

    context 'data_management_plan_creation' do
      before :each do
        @dmp = create(:project, :complete).data_management_plans.first
      end

      context 'for a Doorkeeper::Application' do
        before :each do
          @profile.data_management_plan_creation = true
        end

        it 'returns an empty array if the application is not authorized' do
          @profile.data_management_plan_creation = false
          expect(@profile.authorized_entities(entity_clazz: DataManagementPlan)).to eql([])
        end
        it 'returns an empty array if the application is authorized but no awards match the rules' do
          expect(@profile.authorized_entities(entity_clazz: DataManagementPlan)).to eql([])
        end
        it 'returns the correct dmp ids for an authorized application' do
          create(:oauth_authorization, oauth_application: @profile.oauth_application, data_management_plan: @dmp)
          expect(@profile.authorized_entities(entity_clazz: DataManagementPlan).first).to eql(@dmp.id)
        end
      end
    end

    context 'award_assertion' do
      before :each do
        @award = create(:award, :complete)

        @profile.award_assertion = true
        @profile.rules = {
          award_assertion: <<~SQL
            SELECT a.id
             FROM awards a
             INNER JOIN organizations o ON a.organization_id = o.id
             INNER JOIN identifiers i ON o.id = i.identifiable_id
               AND i.identifiable_type = \'Organization\'
             WHERE i.category = 1
             AND i.value = \'http://dx.doi.org/10.13039/100000104\'
          SQL
        }
      end

      it 'returns an empty array if the application is not authorized' do
        @profile.award_assertion = false
        expect(@profile.authorized_entities(entity_clazz: Award)).to eql([])
      end
      it 'returns an empty array if the application is authorized but no awards match the rules' do
        expect(@profile.authorized_entities(entity_clazz: Award)).to eql([])
      end
      it 'returns the correct award ids for an authorized application' do
        @award.organization.identifiers << create(:identifier,
                                                  category: 'doi',
                                                  identifiable: @award.organization,
                                                  value: 'http://dx.doi.org/10.13039/100000104')
        expect(@profile.authorized_entities(entity_clazz: Award).first).to eql(@award.id)
      end
    end
  end
end
