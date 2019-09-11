# frozen_string_literal: true

# Respresents a user of the API
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable

  enum role: %i[user admin super_user]

  # Doorkeeper associations
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id, dependent: :delete_all

  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id, dependent: :delete_all

  # Validations
  validates :accept_terms, acceptance: true
  validates :first_name, :last_name, :email, :role, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :ensure_role

  # Instance Methods
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

  def ensure_role
    role = 'user' unless role.present?
  end
end
