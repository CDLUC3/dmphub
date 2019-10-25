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

    it 'correctly authorizes an award_assertion' do
      award = create(:award, :complete)
      @profile.award_assertion = true
      @profile.rules = {
        award_assertion: <<~SQL
          SELECT a.id
           FROM awards a
           INNER JOIN organizations o ON a.organization_id = o.id
           INNER JOIN identifiers i ON o.id = i.identifiable_id
             AND i.identifiable_type = \'Organization\'
           WHERE i.category = \'doi\'
           AND i.value = \'http://dx.doi.org/10.13039/100000104\'
        SQL
      }.to_json

p Award.all

      awards = @profile.authorized_entities(entity_clazz: Award)
      p "GOT: #{awards.first[0]}"
    end
  end
end
