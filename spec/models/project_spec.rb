# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_on) }
    it { is_expected.to validate_presence_of(:end_on) }
  end

  context 'associations' do
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:awards) }
  end

  it 'factory can produce a valid model' do
    model = create(:project)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'projects.json')
    end

    it 'invalid JSON does not create a valid Project instance' do
      validate_invalid_json_to_model(clazz: Project, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Project instance' do
      obj = validate_minimal_json_to_model(clazz: Project, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.start_on.to_s).to eql(@json['start_on'])
      expect(obj.end_on.to_s).to eql(@json['end_on'])
    end

    it 'complete JSON creates a valid Project instance' do
      obj = validate_complete_json_to_model(clazz: Project, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.start_on.to_s).to eql(@json['start_on'])
      expect(obj.end_on.to_s).to eql(@json['end_on'])
      expect(obj.awards.first.funder_uri).to eql(@json['funding'].first['funder_id'])
    end

    it 'finds the existing record rather than creating a new instance' do
      project = create(:project, title: @jsons['minimal']['title'])
      obj = Project.from_json(
        provenance: Faker::Lorem.word,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(project.id).to eql(obj.id)
    end
  end
end
