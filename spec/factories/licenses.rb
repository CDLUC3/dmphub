# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id              :bigint           not null, primary key
#  distribution_id :bigint
#  license_ref     :string(255)      not null
#  start_date      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provenance_id   :bigint
#
FactoryBot.define do
  factory :license do
    license_ref  { Faker::Internet.url }
    start_date   { (Time.now + 30.days).utc }

    before :create do |license|
      license.provenance = build(:provenance) unless license.provenance.present?
    end
  end
end
