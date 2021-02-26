# frozen_string_literal: true

# == Schema Information
#
# Table name: provenances
#
#  id          :bigint           not null, primary key
#  name        :string(255)      not null
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Provenance, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'should validate that name is unique' do
      subject.name = Faker::Lorem.unique.word
      is_expected.to validate_uniqueness_of(:name)
        .case_insensitive
        .with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:alterations) }
  end

  it 'factory can produce a valid model' do
    model = build(:provenance)
    expect(model.valid?).to eql(true)
  end

  context 'name=(val)' do
    it 'forces downcase' do
      model = build(:provenance, name: 'Foo')
      expect(model.name).to eql('foo')
      model.name = 'fOo'
      expect(model.name).to eql('foo')
      model.name = 'fOO'
      expect(model.name).to eql('foo')
      model.name = 'f00'
      expect(model.name).to eql('f00')
    end
    it 'converts spaces to underscores' do
      model = build(:provenance, name: 'Foo Bar')
      expect(model.name).to eql('foo_bar')
    end
  end
end
