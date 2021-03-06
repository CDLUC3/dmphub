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
class ApiClient < ApplicationRecord
  # If the Client_id or client_secret are nil generate them
  before_validation :generate_credentials,
                    if: proc { |c| c.client_id.blank? || c.client_secret.blank? }

  # Force the name to downcase
  before_save :name_to_downcase

  # ================
  # = Associations =
  # ================

  has_many :authorizations, class_name: 'ApiClientAuthorization', dependent: :destroy
  has_many :history, class_name: 'ApiClientHistory', dependent: :destroy
  has_many :permissions, class_name: 'ApiClientPermission', dependent: :destroy

  # ===============
  # = Validations =
  # ===============

  # Using case_sensitive here because callback always forces name to lower case
  validates :name, presence: true, uniqueness: { case_sensitive: true }
  validates :contact_email, presence: true, email: { allow_nil: false }

  # ===========================
  # = Public instance methods =
  # ===========================

  # Override the to_s method to keep the id and secret hidden
  def to_s
    name
  end

  # Verify that the incoming secret matches
  def authenticate(secret:)
    client_secret == secret
  end

  # Generate UUIDs for the client_id and client_secret
  def generate_credentials
    self.client_id = SecureRandom.uuid
    self.client_secret = SecureRandom.uuid
  end

  def can_create_data_management_plans?
    permissions.map(&:permission).include?('data_management_plan_creation')
  end

  def can_assert_funding?
    permissions.map(&:permission).include?('funding_assertion')
  end

  def can_assert_contributors?
    permissions.map(&:permission).include?('contributor_assertion')
  end

  protected

  def name_to_downcase
    self.name = name.downcase if name.present?
  end
end
