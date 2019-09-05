# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Description, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to define_enum_for(:category).with(Description.categories.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:describable) }
  end

  it 'factory can produce a valid model' do
    model = create(:data_management_plan_description)
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Describable'
    model = create(:dataset_description)
    expect(model.valid?).to eql(true), 'expected Dataset to be Describable'
    model = create(:project_description)
    expect(model.valid?).to eql(true), 'expected Project to be Describable'
  end

  context 'instance methods' do
    before(:each) do
      @desc = build(:dataset_description)
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @desc.to_json
        expect(json['category']).to eql(@desc.category)
        expect(json['value']).to eql(@desc.value)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T21:11:30.894Z",
#   "value"=>"Nisi ut eius. Quos dolor reiciendis. Possimus aut adipisci.",
#   "category"=>"ethical_issue"
# }
