# frozen_string_literal: true

# == Schema Information
#
# Table name: hosts
#
#  id                  :bigint           not null, primary key
#  title               :string(255)      not null
#  description         :text(4294967295)
#  supports_versioning :boolean
#  backup_type         :string(255)
#  backup_frequency    :string(255)
#  storage_type        :string(255)
#  availability        :string(255)
#  geo_location        :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  certified_with      :text(65535)
#  pid_system          :text(65535)
#  provenance_id       :bigint
#
FactoryBot.define do
  factory :host do
    title                 { Faker::Lorem.sentence }
    description           { Faker::Lorem.paragraph }
    supports_versioning   { [nil, true, false].sample }
    backup_type           { Faker::Lorem.word }
    backup_frequency      { Faker::Lorem.word }
    storage_type          { Faker::Lorem.word }
    availability          { Faker::Lorem.word }
    geo_location          { Faker::Movies::StarWars.planet }

    before :create do |host|
      host.provenance = build(:provenance) unless host.provenance.present?
    end

    trait :complete do
      transient do
        identifiers_count { 1 }
      end

      after :create do |host, evaluator|
        evaluator.identifiers_count.times do
          host.identifiers << create(:identifier, category: 'url', identifiable: host,
                                                  descriptor: Identifier.descriptors.keys.sample,
                                                  provenance: host.provenance)
        end
      end
    end
  end
end
