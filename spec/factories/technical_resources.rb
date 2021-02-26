# frozen_string_literal: true

# == Schema Information
#
# Table name: technical_resources
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string(255)      not null
#  provenance_id :bigint
#
FactoryBot.define do
  factory :technical_resource do
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    before :create do |technical_resource|
      technical_resource.provenance = build(:provenance) unless technical_resource.provenance.present?
    end
  end
end
