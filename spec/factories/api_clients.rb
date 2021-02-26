# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id            :bigint           not null, primary key
#  name          :string(255)      not null
#  description   :string(255)
#  homepage      :string(255)
#  contact_name  :string(255)
#  contact_email :string(255)      not null
#  client_id     :string(255)      not null
#  client_secret :string(255)      not null
#  last_access   :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :api_client do
    name { Faker::Movies::StarWars.unique.planet.downcase }
    description { Faker::Lorem.sentence }
    homepage { Faker::Internet.url }
    contact_name { Faker::Movies::StarWars.character }
    contact_email { Faker::Internet.email }
    client_id { SecureRandom.uuid }
    client_secret { SecureRandom.uuid }
    last_access { Time.now - 2.days }

    after :create do |api_client, _evaluator|
      api_client.permissions << create(:api_client_permission, api_client: api_client)
      create(:provenance, name: api_client.name)
    end

    trait :complete do
      transient do
        authorization_count { 1 }
        history_per_authorization_count { 1 }
      end

      after :create do |api_client, evaluator|
        evaluator.authorization_count.times do
          dmp = create(:data_management_plan, :complete)
          auth = create(:api_client_authorization, api_client: api_client,
                                                   data_management_plan: dmp)
          api_client.authorizations << auth

          evaluator.history_per_authorization_count.times do
            history = create(:api_client_history, api_client: api_client,
                                                  data_management_plan: dmp)
            api_client.hostory << history
          end
        end
      end
    end
  end
end
