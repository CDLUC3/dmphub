# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:language) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:costs) }
    it { is_expected.to have_many(:datasets) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:oauth_authorization) }
  end

  it 'factory can produce a valid model' do
    model = build(:data_management_plan)
    expect(model.valid?).to eql(true)
  end

  context 'scopes' do
    describe 'for_client' do
      before(:each) do
        @app = create(:doorkeeper_application)
        @dmps = [
          create(:data_management_plan, doorkeeper_application: @app),
          create(:data_management_plan, doorkeeper_application: @app)
        ]
        @other_dmp = create(:data_management_plan)
      end

      it 'returns only the data_management_plans that belong to the client/application' do
        dmps = DataManagementPlan.by_client(client_id: @app.uid).pluck(:data_management_plan_id)
        expect(dmps.length).to eql(2)
        expect(dmps.include?(@other_dmp.id)).to eql(false)
        @dmps.each { |dmp| expect(dmps.include?(dmp.id)).to eql(true) }
      end
    end
  end

  context 'instance methods' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete)
    end

    describe 'primary_contact' do
      it 'returns the primary_contact and only the primary_contact' do
        expect(@dmp.primary_contact.is_a?(PersonDataManagementPlan)).to eql(true)
        expect(@dmp.primary_contact).to eql(PersonDataManagementPlan
          .where(role: 'primary_contact', data_management_plan_id: @dmp.id).first)
      end
    end

    describe 'persons' do
      before(:each) do
        @persons = @dmp.persons
      end
      it 'does not include the primary_contact' do
        expect(@persons.include?(@dmp.primary_contact)).to eql(false)
      end
      it 'includes all non-primary_contact persons' do
        PersonDataManagementPlan.where(data_management_plan_id: @dmp_id).where.not(role: 'primary_contact').each do |p|
          expect(@persons.include?(p)).to eql(true)
        end
      end
    end

  end
end
