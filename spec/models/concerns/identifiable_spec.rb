# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifiable do
  # Using the Affiliation model for testing this Concern
  before(:each) do
    @provenance = create(:provenance)
    @affiliation = create(:affiliation, provenance: @provenance)
    @category = Identifier.categories.keys.map(&:to_s).sample
    @id1 = create(:identifier, provenance: @provenance, category: @category,
                               identifiable: @affiliation)
    @affiliation.reload
  end

  context 'associations' do
    it 'has a have_many relationship with :identifiers' do
      expect(Affiliation.new.respond_to?(:identifiers)).to eql(true)
    end
  end

  context 'instance methods' do
    describe '#[category.pluralize] helper methods (e.g. ".rors")' do
      Identifier.categories.each_key do |category|
        it "returns the :#{category} identifier" do
          @id1.update(category: category)
          expect(@affiliation.send(:"#{category.pluralize}").include?(@id1)).to eql(true)
        end
        it "does not return the :#{category} identifier" do
          @id1.update(category: Identifier.categories.keys.reject { |k| k == category }.first)
          expect(@affiliation.send(:"#{category.pluralize}").include?(@id1)).to eql(false)
        end
      end
    end
  end

  context 'class methods' do
    describe '#find_by_[category] scopes' do
      Identifier.categories.each_key do |category|
        it 'returns the correct identifiers' do
          @id1.update(category: category)
          result = Affiliation.send(:"find_by_#{category}", @id1.value)
          expect(result.include?(@affiliation)).to eql(true)
        end
        it 'does not return other categories' do
          @id1.update(category: Identifier.categories.keys.reject { |k| k == category }.first)
          result = Affiliation.send(:"find_by_#{category}", @id1.value)
          expect(result.include?(@affiliation)).to eql(false)
        end
      end
    end

    describe '#find_by_identifiers(provenance:, json_array:)' do
      before(:each) do
        @json = [{ category: @id1.category, value: @id1.value }]
      end
      it 'returns nil if json_array is not an array' do
        result = Affiliation.find_by_identifiers(provenance: @provenance, json_array: nil)
        expect(result).to eql(nil)
      end
      it 'returns nil if provenance is not present' do
        result = Affiliation.find_by_identifiers(provenance: nil, json_array: @json)
        expect(result).to eql(nil)
      end
      it 'returns the correct identifiable' do
        result = Affiliation.find_by_identifiers(provenance: @provenance, json_array: @json)
        expect(result).to eql(@affiliation)
      end
    end

    describe 'private #find_association(provenance:, json:)' do
      it 'returns the correct identifiable' do
        contributor = create(:contributor)
        identifier = create(:identifier, identifiable: contributor, provenance: @provenance,
                                         category: @category)
        json = { category: @category, value: identifier.value }
        result = Contributor.send(:find_association, provenance: @provenance, json: json)
        expect(result).to eql(contributor)
      end
    end
  end
end
