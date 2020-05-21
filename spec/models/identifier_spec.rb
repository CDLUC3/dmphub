# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:provenance) }

    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }
    it { is_expected.to define_enum_for(:descriptor).with(Identifier.descriptors.keys) }

    it 'should validate that :value is unique per :category + :provenance + :identifiable' do
      required = Identifier.send(:requires_universal_uniqueness)
      category = Identifier.categories.keys.reject { |i| required.include?(i) }.first
      create(:identifier, category: category, identifiable: create(:contributor))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category, :provenance, :identifiable_id)
                                                   .case_insensitive.with_message('has already been taken')
    end
    it 'should validate that :value is unique per :category' do
      category = Identifier.send(:requires_universal_uniqueness).first
      create(:identifier, category: category, identifiable: create(:contributor))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category)
                                                   .case_insensitive.with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }
  end

  it 'factory can produce a valid model' do
    model = create(:identifier, identifiable: create(:funding, affiliation: create(:affiliation)))
    expect(model.valid?).to eql(true), 'expected Award to be Identifiable'
    model = create(:identifier, identifiable: create(:data_management_plan, project: create(:project)))
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Identifiable'
    model = create(:identifier, identifiable: create(:dataset))
    expect(model.valid?).to eql(true), 'expected Dataset to be Identifiable'
    model = create(:identifier, identifiable: create(:host))
    expect(model.valid?).to eql(true), 'expected Host to be Identifiable'
    model = create(:identifier, identifiable: create(:metadatum))
    expect(model.valid?).to eql(true), 'expected Metadatum to be Identifiable'
    model = create(:identifier, identifiable: create(:affiliation))
    expect(model.valid?).to eql(true), 'expected Organization to be Identifiable'
    model = create(:identifier, identifiable: create(:contributor))
    expect(model.valid?).to eql(true), 'expected Person to be Identifiable'
  end

  describe '#by_provenance_and_category_and_value(provenance:, category: value:)' do
    before(:each) do
      @provenance = Faker::Lorem.unique.word
      @identifiable = create(:affiliation)
      @value = SecureRandom.uuid
    end

    context 'a category that is universally unique (e.g. doi, url, etc.)' do
      before(:each) do
        @category = described_class.send(:requires_universal_uniqueness).first
        @expected = create(:identifier, category: @category, provenance: @provenance,
                                        identifiable: @identifiable, value: @value)
      end

      it 'same identifiable and category but different provenance' do
        results = described_class.by_provenance_and_category_and_value(
          provenance: Faker::Lorem.unique.word.downcase, category: @category, value: @value
        )
        expect(results.first).to eql(@expected)
        expect(results.length).to eql(1)
      end
    end

    context 'a category that is not universally unique (e.g. program)' do
      before(:each) do
        required = described_class.send(:requires_universal_uniqueness)
        @category = described_class.categories.keys.reject { |i| required.include?(i) }.first
        @expected = create(:identifier, category: @category, provenance: @provenance,
                                        identifiable: @identifiable, value: @value)
      end

      it 'same identifiable and category but different provenance' do
        # The one it should not find
        create(:identifier, category: @category, provenance: Faker::Lorem.unique.word.downcase,
                            identifiable: @identifiable, value: @value)
        results = described_class.by_provenance_and_category_and_value(
          provenance: @provenance, category: @category, value: @value
        )
        expect(results.first).to eql(@expected)
        expect(results.length).to eql(1)
      end
      it 'same identifiable and provenance but different category' do
        # The one it should not find
        create(:identifier, category: described_class.categories.keys.last,
                            provenance: @provenance, identifiable: @identifiable,
                            value: @value)
        results = described_class.by_provenance_and_category_and_value(
          provenance: @provenance, category: @category, value: @value
        )
        expect(results.first).to eql(@expected)
        expect(results.length).to eql(1)
      end
    end
  end
end
