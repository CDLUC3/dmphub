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

  context 'instance methods' do
    before(:each) do
      @status = build(:award_status)
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @status.to_json
        expect(json['status']).to eql(@status.status)
        expect(json['links'].present?).to eql(false)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T21:11:30.894Z",
#   "status"=>"granted",
#   "provenance"=>"nsf_award_api"
# }
