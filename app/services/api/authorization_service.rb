# frozen_string_literal: true

module Api
  # Service that handles authorizations on a DMP
  class AuthorizationService

    class << self

      def authorize!(dmp:, entity:)
        return nil unless dmp.present? && dmp.is_a?(DataManagementPlan) && !dmp.new_record?
        return nil unless entity.present? && entity.is_a?(Doorkeeper::Application)

        OauthAuthorization.find_or_create_by(oauth_application: entity, data_management_plan: dmp)
      end

      def authorized?(dmp:, entity:, permission:)
        return false unless permission.present?
        return false unless dmp.present? && dmp.is_a?(DataManagementPlan)
        return false unless entity.present? && (entity.is_a?(User) || entity.is_a?(Doorkeeper::Application))

        return true if entity.is_a?(User) && entity.role == 'super_user'

        return authorized_person?(dmp: dmp, person: user_to_person(user: entity)) if entity.is_a?(User)

        authorized_application?(dmp: dmp, application: entity)
      end

      private

      def authorized_user?(dmp:, person:)
        PersonDataManagementPlan.where(
          role: %w[primary_contact principal_investigator],
          data_management_plan_id: dmp.id,
          person_id: person.id
        ).any?
      end

      def authorized_application?(dmp:, application:)
        OauthAuthorization.where(data_management_plan: dmp, oauth_application: application).any?
      end

      def user_to_person(user:)
        Person.joins(:identifiers).includes(:identifiers)
              .where(identifiers: { value: user.orcid, category: 'orcid' }).first
      end
    end

  end
end
