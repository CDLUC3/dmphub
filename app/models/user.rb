# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable

  # Doorkeeper associations
  has_many :oauth_applications, class_name: "Doorkeeper::Application", as: :owner

  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
           foreign_key: :resource_owner_id, dependent: :delete_all

  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id, dependent: :delete_all

  # Associations
  belongs_to :application

  # Validations
  validates :accept_terms, acceptance: true

  after_create :generate_api_token!

  def name
    return email if first_name.nil? && last_name.nil?

    [first_name, last_name].join(' ')&.squish
  end

  def first_name=(value)
    super(value&.humanize)
  end

  def last_name=(value)
    super(value&.humanize)
  end

  # JSON for API
  def to_json(options = {})
    JSON.parse(super(only: %i[id first_name last_name email])).to_json
  end

  private

  def generate_api_token!
    return false unless email.present?
    payload = {
      user_id: id,
      email: email,
      username: name,
      secret: TokenService.generate_uuid
    }
    update(secret: TokenService.encode(payload.to_json))
  end

end
