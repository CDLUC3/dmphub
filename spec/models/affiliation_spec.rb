# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Affiliation, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it 'validates uniqueness of name' do
      subject = create(:affiliation)
      expect(subject).to validate_uniqueness_of(:name).case_insensitive
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:contributors) }
    it { is_expected.to have_many(:authorizations) }
    it { is_expected.to have_many(:alterations) }
    it { is_expected.to have_many(:identifiers) }
  end

  describe 'cascading deletes' do
    it 'does not delete associated contributors' do
      model = create(:affiliation, :complete)
      contributor = create(:contributor, affiliation: model)
      model.destroy
      expect(Contributor.last).to eql(contributor)
    end
    it 'deletes associated identifiers' do
      model = create(:affiliation, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
    it 'deletes associated authorizations' do
      model = create(:affiliation, :complete)
      create(:api_client_authorization, authorizable: model,
                                        api_client: create(:api_client))
      authorization = model.reload.authorizations.first
      model.destroy
      expect(ApiClientAuthorization.where(id: authorization.id).empty?).to eql(true)
    end
  end

  it 'factory can produce a valid model' do
    model = create(:affiliation)
    expect(model.valid?).to eql(true)
  end

  describe 'serilized attributes' do
    before(:each) do
      @model = build(:affiliation)
    end

    it 'returns :attrs as a hash' do
      expect(@model.attrs.is_a?(Hash)).to eql(true)
    end
    it 'returns :types as an array' do
      expect(@model.types.is_a?(Array)).to eql(true)
    end
    it 'returns :alternate_names as an array' do
      expect(@model.alternate_names.is_a?(Array)).to eql(true)
    end
    it 'saves :attrs properly' do
      hash = { 'foo': 'bar' }
      @model.attrs = hash
      @model.save
      expect(@model.attrs).to eql(hash)
    end
    it 'saves :alternate_names properly' do
      array = %w[foo bar]
      @model.alternate_names = array
      @model.save
      expect(@model.alternate_names).to eql(array)
    end
    it 'saves :types properly' do
      array = %w[foo bar]
      @model.types = array
      @model.save
      expect(@model.types).to eql(array)
    end
  end

  context 'private methods' do
    describe '#ensure_defaults' do
      before(:each) do
        @model = build(:affiliation, attrs: nil, types: nil, alternate_names: nil)
        @model.valid?
      end

      it 'sets the default for :attrs' do
        expect(@model.attrs).to eql({})
      end
      it 'sets the default for :types' do
        expect(@model.types).to eql([])
      end
      it 'sets the default for :alternate_names' do
        expect(@model.alternate_names).to eql([])
      end
    end
  end
end
