# frozen_string_literal: true

FactoryBot.define do
  factory :award_status do
    award
    status { AwardStatus.statuses.keys.sample }
  end
end
