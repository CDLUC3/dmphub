# frozen_string_literal: true

# == Schema Information
#
# Table name: costs
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  description             :text(4294967295)
#  value                   :float(24)
#  currency_code           :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
FactoryBot.define do
  factory :cost do
    title                 { Faker::Lorem.sentence }
    description           { Faker::Lorem.paragraph }
    value                 { Faker::Number.decimal(l_digits: 2) }
    currency_code         { %w[usd gbd cad].sample }

    before :create do |cost|
      cost.provenance = build(:provenance) unless cost.provenance.present?
    end
  end
end
