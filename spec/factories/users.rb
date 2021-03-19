# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)      not null
#  secret                 :text(65535)
#  role                   :integer          default("user"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  orcid                  :string(255)
#  affiliation_id         :bigint
#
FactoryBot.define do
  factory :user do
    first_name          { Faker::Name.first_name }
    last_name           { Faker::Name.last_name }
    email               { Faker::Internet.unique.safe_email }
    password            { 'password' }
    accept_terms        { true }
    role                { 'user' }
    secret              { Faker::Crypto.sha256 }

    trait :complete do
      after :create do |user|
        user.affiliation = create(:affiliation) unless user.affiliation.present?
      end
    end
  end
end
