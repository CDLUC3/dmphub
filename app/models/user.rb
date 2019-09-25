# frozen_string_literal: true

# Respresents a user of the API
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, omniauth_providers: %i[orcid]

  enum role: %i[user admin super_user]

  # Doorkeeper associations
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id, dependent: :delete_all

  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id, dependent: :delete_all

  belongs_to :organization, optional: true

  # Validations
  validates :accept_terms, acceptance: true
  validates :first_name, :last_name, :email, :role, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :ensure_role

  # Class Methods
  class << self
    def from_omniauth_orcid(auth_hash:)
      users = find_by_orcid_or_email(auth_hash: auth_hash)
      raise 'More than one user matches the ID or email returned by ORCID' if users.count > 1
      return users.first if users.first.present?

      initialize_user_with_orcid(auth_hash: auth_hash)
    end

    def find_by_orcid_or_email(auth_hash:)
      where(orcid: auth_hash[:uid]).or(where(email: auth_hash[:info]['email']))
    end

    private

    def initialize_user_with_orcid(auth_hash:)
      User.new(
        first_name: auth_hash[:info]['first_name'],
        last_name: auth_hash[:info]['last_name'],
        email: auth_hash[:info]['email'],
        last_sign_in_at: Time.new.utc,
        role: 'user',
        orcid: auth_hash[:uid]
      )
    end
  end

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
    @role = 'user' unless @role.present?
  end

  def data_management_plans
    if user?
      ident = Identifier.where(value: orcid, category: 'orcid', identifiable_type: 'Person').first
      return [] unless ident.present?

      person = Person.where(id: ident.identifiable_id).first
      return [] unless person.present?

      ids = PersonDataManagementPlan.where(person_id: person.id).pluck(:data_management_plan_id)
      DataManagementPlan.where(id: ids)
    end
  end

  # convenience method for updating and returning user
  def update_user_orcid(auth_hash:)
    update(orcid: auth_hash[:uid]) unless orcid.present?
    update(last_sign_in_at: Time.new.utc)
    update(first_name: auth_hash[:info]['first_name']) if auth_hash[:info]['first_name'].present?
    update(last_name: auth_hash[:info]['last_name']) if auth_hash[:info]['last_name'].present?
    update(email: auth_hash[:info]['email']) if auth_hash[:info]['email'].present?
    self
  end
end
