# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alterable do
  context 'associations' do
    subject { build(:data_management_plan) }

    it { is_expected.to belong_to(:provenance) }
    it { is_expected.to have_many(:alterations) }
  end

  context 'cascading deletes' do
    it 'does not delete associated provenance' do
      model = create(:affiliation, :complete, provenance: create(:provenance))
      provenance = model.provenance
      model.destroy
      expect(Provenance.where(id: provenance.id).empty?).to eql(false)
    end
    it 'does not delete associated alterations' do
      model = create(:affiliation, :complete)
      alteration = model.alterations.first
      model.destroy
      expect(Alteration.where(id: alteration.id).empty?).to eql(false)
    end
  end

  context 'instance methods' do
    before(:each) do
      @model = build(:data_management_plan, provenance: build(:provenance))
    end

    describe '#record_alterations callback' do
      it 'does not add an alteration if nothing changed' do
        @model.save
        @model.send(:record_alterations)
        expect(@model.alterations.length).to eql(1)
      end
      it 'adds an alteration if its a new record' do
        @model.send(:record_alterations)
        expect(@model.alterations.length).to eql(1)
      end
      it 'adds an alteration if something was updated' do
        @model.save
        @model.title = Faker::Music::PearlJam.song
        @model.send(:record_alterations)
        expect(@model.alterations.length).to eql(2)
      end
      it 'adds an alteration if a field was set to nil' do
        @model.save
        @model.description = nil
        @model.send(:record_alterations)
        expect(@model.alterations.length).to eql(2)
      end
    end
  end
end
