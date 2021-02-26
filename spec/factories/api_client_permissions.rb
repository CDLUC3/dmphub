# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_permissions
#
#  id            :bigint           not null, primary key
#  api_client_id :bigint           not null
#  permission    :integer          not null
#  rules         :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :api_client_permission do
    permission { ApiClientPermission.permissions.keys.map(&:to_s).sample }
  end
end
