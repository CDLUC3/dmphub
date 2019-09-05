# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:provenance) }
    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }

    it 'should validate that :value is unique per :category+:provenance' do
      create(:identifier, category: Identifier.categories.keys.sample, identifiable: create(:person))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category, :provenance)
                                                   .case_insensitive.with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }
  end

  it 'factory can produce a valid model' do
    model = create(:award_identifier)
    expect(model.valid?).to eql(true), 'expected Award to be Identifiable'
    model = create(:data_management_plan_identifier)
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Identifiable'
    model = create(:dataset_identifier)
    expect(model.valid?).to eql(true), 'expected Dataset to be Identifiable'
    model = create(:person_identifier)
    expect(model.valid?).to eql(true), 'expected Person to be Identifiable'
  end

  context 'instance methods' do
    before(:each) do
      @ident = build(:dataset_identifier)
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @ident.to_json
        expect(json['provenance']).to eql(@ident.provenance)
        expect(json['category']).to eql(@ident.category)
        expect(json['value']).to eql(@ident.value)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T21:11:30.894Z",
#   "value"=>"10.1234/abc123.98zy",
#   "category"=>"doi",
#   "provenance"=>"datacite"
# }
