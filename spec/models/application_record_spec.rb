# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do

  before(:each) do
    @model = create(:dataset)
  end

  describe '#to_hateoas' do
    before(:each) do
      @hateoas = JSON.parse(@model.to_hateoas)
    end

    it 'returns the default relationship' do
      expect(@hateoas['rel']).to eql('self')
    end

    it 'returns the specified relationship' do
      hateoas = JSON.parse(@model.to_hateoas('tested_by'))
      expect(hateoas['rel']).to eql('tested_by')
    end

    it 'returns the default href' do
      expect(@hateoas['href']).to eql(Rails.application.routes.url_helpers.api_v1_dataset_url(@model.id))
    end

    it 'returns the specified href' do
      hateoas = JSON.parse(@model.to_hateoas(nil, 'http://example.org'))
      expect(hateoas['href']).to eql('http://example.org')
    end
  end

  describe '#to_json' do
    before(:each) do
      @json = @model.to_json
    end

    it 'returns the default attributes' do
      expect(@json['created_at']).to eql(@model.created_at.strftime("%FT%T.%3NZ"))
      expect(@json['links'].first).to eql(JSON.parse(@model.to_hateoas))
    end

    it 'skips the HATEOAS `links` if `:no_hateoas` is sent in the options' do
      json = @model.to_json(%i[no_hateoas])
      expect(json['links'].present?).to eql(false)
    end

    it 'returns a links section with the hateoas' do
      expect(@json['links'].first).to eql(JSON.parse(@model.to_hateoas))
    end

    it 'does not return attributes we do not specify' do
      expect(@json['updated_at'].present?).to eql(false)
    end

    it 'returns attributes we specify' do
      # We're using Award here for testing so see its definition for the attributes
      expect(@json['title']).to eql(@model.title)
    end
  end
end
