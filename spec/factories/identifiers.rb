# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                :bigint           not null, primary key
#  value             :string(255)      not null
#  category          :integer          default("ark"), not null
#  identifiable_id   :bigint
#  identifiable_type :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  descriptor        :integer          default("is_funded_by")
#  provenance_id     :bigint
#
FactoryBot.define do
  # This base factory is not meant to be used directly, use one of the ones below
  factory :identifier do
    category        { Identifier.categories.keys.sample }
    value           { SecureRandom.uuid }
    descriptor      { Identifier.descriptors.keys.sample }

    before :create do |identifier|
      identifier.provenance = build(:provenance) unless identifier.provenance.present?
    end
  end
end
