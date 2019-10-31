# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonOrganization, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:person) }
    it { is_expected.to belong_to(:organization) }
  end

  describe 'cascading deletes' do
    before(:each) do
      @person = create(:person)
      @organization = create(:organization)
      @model = PersonOrganization.create(person: @person, organization: @organization)
      @model.destroy
    end

    it 'does not delete the person' do
      expect(Person.last).to eql(@person)
    end
    it 'does not delete the organization' do
      expect(Organization.last).to eql(@organization)
    end
  end
end
