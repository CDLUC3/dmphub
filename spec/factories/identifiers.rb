# frozen_string_literal: true

FactoryBot.define do
  # This base factory is not meant to be used directly, use one of the ones below
  factory :identifier do
    category        { Identifier.categories.keys.sample }
    provenance      { Faker::Lorem.word.downcase }
    value           { SecureRandom.uuid }
  end

  factory :award_identifier, parent: :identifier do |identifier|
    category { 'url' }
    identifier.identifiable { |i| i.association(:award) }
  end

  factory :data_management_plan_identifier, parent: :identifier do |identifier|
    category { %w[doi url].sample }
    identifier.identifiable { |i| i.association(:data_management_plan) }
  end

  factory :dataset_identifier, parent: :identifier do |identifier|
    category { %w[doi url].sample }
    identifier.identifiable { |i| i.association(:dataset) }
  end

  factory :host_identifier, parent: :identifier do |identifier|
    category { %w[url].sample }
    identifier.identifiable { |i| i.association(:host) }
  end

  factory :metadatum_identifier, parent: :identifier do |identifier|
    category { 'url' }
    identifier.identifiable { |i| i.association(:metadatum) }
  end

  factory :organization_identifier, parent: :identifier do |identifier|
    category { %w[ror grid].sample }
    identifier.identifiable { |i| i.association(:organization) }
  end

  factory :person_identifier, parent: :identifier do |identifier|
    category { %w[orcid url].sample }
    identifier.identifiable { |i| i.association(:person) }
  end

  factory :technical_resource_identifier, parent: :identifier do |identifier|
    category { %w[doi url].sample }
    identifier.identifiable { |i| i.association(:technical_resource) }
  end
end
