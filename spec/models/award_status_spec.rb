# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AwardStatus, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:provenance) }
    it { is_expected.to define_enum_for(:status).with(AwardStatus.statuses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:award) }
  end

  it 'factory can produce a valid model' do
    model = build(:award_status)
    expect(model.valid?).to eql(true)
  end

  context 'scopes' do
    before(:each) do
      @json = {
        'created_at': Time.now.to_s,
        'status': AwardStatus.statuses.keys.sample
      }
    end

    describe 'from_json' do
      it 'converts the expected json into an Identifier model' do
        award_status = AwardStatus.from_json(@json, Faker::Lorem.word)
        expect(award_status.created_at.to_s).not_to eql(@json[:created_at])
        expect(award_status.status).to eql(@json[:status])
        expect(award_status.provenance).not_to eql(nil)
      end
    end
  end
end
