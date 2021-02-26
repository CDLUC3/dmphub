# frozen_string_literal: true

# == Schema Information
#
# Table name: security_privacy_statements
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  title         :string(255)      not null
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provenance_id :bigint
#
FactoryBot.define do
  factory :security_privacy_statement do
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    before :create do |security_privacy_statement|
      security_privacy_statement.provenance = build(:provenance) unless security_privacy_statement.provenance.present?
    end
  end
end
