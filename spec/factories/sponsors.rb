# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id                       :bigint           not null, primary key
#  name                     :string(255)      not null
#  name_type                :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  data_management_plan_id  :bigint           not null
#  provenance_id            :bigint
#
FactoryBot.define do
  factory :sponsor do
    name      { Faker::Company.unique.name }
    name_type { Sponsor.name_types.keys.sample }

    before :create do |license|
      license.provenance = build(:provenance) unless license.provenance.present?
    end
  end
end
